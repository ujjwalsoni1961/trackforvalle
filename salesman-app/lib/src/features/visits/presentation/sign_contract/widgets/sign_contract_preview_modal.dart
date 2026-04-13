import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
// ignore: unused_import
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:signature/signature.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/submit_contract_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/widgets/contract_preview.dart';
import 'package:track/src/features/visits/presentation/visit_log/cubit/visit_log_cubit.dart';

// Web-compatible file wrapper for signature bytes
// ignore: unused_element
class _WebCompatibleFile implements File {
  final Uint8List _bytes;
  final String _path;

  _WebCompatibleFile(this._bytes, this._path);

  @override
  Uint8List readAsBytesSync() => _bytes;

  @override
  String get path => _path;

  // Implement other File methods as no-ops or throw unsupported
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class ContractPreviewModal extends StatefulWidget {
  final String templateString;
  final Map<String, String> formData;
  final Map<String, String> dropdownValues;
  final int leadID;
  final int contractTemplateID;
  final String? pdfUrl;

  const ContractPreviewModal({
    super.key,
    required this.templateString,
    required this.formData,
    this.dropdownValues = const {},
    required this.leadID,
    required this.contractTemplateID,
    this.pdfUrl,
  });

  @override
  State<ContractPreviewModal> createState() => _ContractPreviewModalState();
}

class _ContractPreviewModalState extends State<ContractPreviewModal> {
  final SignatureController _signatureController = SignatureController(
    penStrokeWidth: 2,
    penColor: Colors.black,
    exportBackgroundColor: Colors.transparent,
  );
  

  String _replaceVariables(String template) {
    String result = template;
    
    // Replace regular form data fields
    widget.formData.forEach((key, value) {
      result = result.replaceAll('{$key}', value);
    });
    
    // Replace dropdown fields (format: {dropdown:field_name})
    widget.dropdownValues.forEach((key, value) {
      result = result.replaceAll('{dropdown:$key}', value);
    });
    
    // Replace {signature_image} with placeholder text for preview
    result = result.replaceAll('{signature_image}', '[Signature will appear here after signing]');
    
    return result;
  }

  void _submitForm() async {
    if (_signatureController.isEmpty) {
      // ignore: use_build_context_synchronously
      context.errorBar("Please sign the contract!");
      return;
    }

    final bytes = await _signatureController.toPngBytes();
    if (bytes == null) {
      // ignore: use_build_context_synchronously
      context.errorBar("Failed to capture signature");
      return;
    }

    final base64Sig = 'data:image/png;base64,${base64Encode(bytes)}';

    // Combine form data and dropdown values
    final allFieldValues = <String, String>{
      ...widget.formData,
      ...widget.dropdownValues,
    };

    // ignore: use_build_context_synchronously
    context.read<SubmitContractCubit>().signContract(
      templateId: widget.contractTemplateID,
      leadId: widget.leadID,
      fieldValues: allFieldValues,
      signatureBase64: base64Sig,
    );
  }

  @override
  void dispose() {
    _signatureController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool hasPdfPreview = widget.pdfUrl != null && widget.pdfUrl!.isNotEmpty;

    return BlocListener<SubmitContractCubit, SubmitContractState>(
      listener: (context, state) {
        if (state is SubmitContractLoading) {
          LoadingAnimation.show(context);
        }
        if (state is SubmitContractFailed) {
          context.pop();
          context.errorBar(state.errorMessage);
        }
        if (state is SubmitContractSuccess) {
          context.read<VisitLogCubit>().setContractID(
            leadID: widget.leadID,
            contractID: state.contractID,
          );
          context.read<VisitLogCubit>().setVisitID(
            leadID: widget.leadID,
            visitID: state.visitID,
          );
          context.read<LeadsDetailsCubit>().getAllTheLeads(pageNumber: 1);
          context.pop();
          context.pop();
          context.pop();
          context.pop();
          context.successBar("Contract Submitted");
        }
      },
      child: Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        backgroundColor: Colors.grey.shade50,
        insetPadding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height - 32,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                hasPdfPreview ? "Sign Contract" : "Contract Preview",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const GapV(12),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: hasPdfPreview
                        ? ContractPreview(
                            templateString: '',
                            pdfUrl: widget.pdfUrl,
                          )
                        : ContractPreview(
                            templateString: _replaceVariables(widget.templateString),
                          ),
                  ),
                ),
              ),
              const GapV(24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Signature",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
              const GapV(12),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: Colors.grey.shade200, width: 1.5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Signature(
                    controller: _signatureController,
                    backgroundColor: Colors.white,
                  ),
                ),
              ),
              const GapV(16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextButton(
                    onPressed: () => _signatureController.clear(),
                    child: Text(
                      "Clear",
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ),
                  const GapH(16),
                  Expanded(
                    child: ButtonPrimary(
                      text: "Submit Signature",
                      onPressed: _submitForm
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
