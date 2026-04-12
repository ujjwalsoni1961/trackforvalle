import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/center_loading_text_widget.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/center_error_widget.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/get_contract_templates_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/docuseal_sign_view.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/sign_contract_view.dart';
import 'package:track/src/features/visits/presentation/sign_contract/widgets/contract_preview.dart';

class LeadIDVisitIDPageParams extends Equatable {
  final int leadId;
  final int visitId;
  final String? currentLeadStatus;

  const LeadIDVisitIDPageParams({
    required this.leadId,
    required this.visitId,
    this.currentLeadStatus,
  });

  @override
  List<Object?> get props => [leadId, visitId, currentLeadStatus];
}

class ChooseContractView extends StatefulWidget {
  final LeadIDVisitIDPageParams params;
  const ChooseContractView({super.key, required this.params});

  @override
  State<ChooseContractView> createState() => _ChooseContractViewState();
}

class _ChooseContractViewState extends State<ChooseContractView> {
  int? _selectedId;
  String _currentTemplateString = '';

  @override
  void initState() {
    super.initState();
    final cubit = context.read<GetContractTemplatesCubit>();
    if (cubit.state is GetContractTemplatesInitial) {
      cubit.getTheContractTemplates();
    }
  }

  List<String> extractTemplateVariables(String templateString, Map<String, DropdownField>? dropdownFields) {
    final RegExp variableRegex = RegExp(r'\{(\w+)\}');
    final RegExp dropdownRegex = RegExp(r'\{dropdown:(\w+)\}');
    
    final matches = variableRegex.allMatches(templateString);
    final dropdownMatches = dropdownRegex.allMatches(templateString);
    
    final variables = matches.map((match) => match.group(1)!).toSet();
    final dropdownVars = dropdownMatches.map((match) => match.group(1)!).toSet();
    
    debugPrint('All extracted variables: $variables');
    debugPrint('Dropdown variables: $dropdownVars');
    
    // Remove signature_image field and dropdown fields from regular variables
    variables.remove("signature_image");
    variables.removeAll(dropdownVars);
    
    debugPrint('Final filtered variables: $variables');
    
    return variables.map((v) => v.toLowerCase()).toSet().toList();
  }

  bool _isCreatingSubmission = false;

  void _submitForm(List<ContractTemplateEntity> templates) {
    if (_selectedId == null) {
      context.errorBar("Choose a template...");
      return;
    }

    final selectedTemplate = templates.firstWhere((t) => t.id == _selectedId);

    // If template has a DocuSeal template ID, create a submission and open WebView
    if (selectedTemplate.hasDocuSeal) {
      _startDocuSealSigning(selectedTemplate);
      return;
    }

    // Otherwise use the existing signing flow
    context.push(
      Routes.signContractView,
      extra: SignContractViewPageParams(
        leadID: widget.params.leadId,
        contractTemplateID: _selectedId!,
        fields: extractTemplateVariables(selectedTemplate.templateString, selectedTemplate.dropdownFields),
        templateString: selectedTemplate.templateString,
        dropdownFields: selectedTemplate.dropdownFields,
      ),
    );
  }

  Future<void> _startDocuSealSigning(ContractTemplateEntity template) async {
    if (_isCreatingSubmission) return;
    setState(() => _isCreatingSubmission = true);

    try {
      final repo = sl<ContractsRepository>();
      final result = await repo.createDocuSealSubmission(
        templateId: template.docusealTemplateId!,
        signerEmail: 'customer@example.com',
        signerName: 'Customer',
        metadata: {
          'lead_id': widget.params.leadId,
          'visit_id': widget.params.visitId,
          'contract_template_id': template.id,
        },
      );

      result.fold(
        (failure) {
          if (mounted) {
            context.errorBar('Failed to create signing session: ${failure.message}');
          }
        },
        (data) {
          final embedSrc = data['embed_src'] as String?;
          if (embedSrc != null && embedSrc.isNotEmpty && mounted) {
            context.push(
              RoutePaths.docusealSign,
              extra: DocuSealSignViewParams(
                signingUrl: embedSrc,
                templateName: template.title,
                leadId: widget.params.leadId,
              ),
            );
          } else if (mounted) {
            context.errorBar('No signing URL received from DocuSeal');
          }
        },
      );
    } catch (e) {
      if (mounted) {
        context.errorBar('Error: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isCreatingSubmission = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Choose Template",
      body: BlocBuilder<GetContractTemplatesCubit, GetContractTemplatesState>(
        builder: (context, state) {
          if (state is GetContractTemplatesFailed) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CenterErrorWidget(error: state.errorMessage),
                TextButton.icon(
                  onPressed: () {
                    context
                        .read<GetContractTemplatesCubit>()
                        .getTheContractTemplates();
                  },
                  label: Text("Retry?"),
                  icon: Icon(Icons.refresh_outlined),
                ),
              ],
            );
          }
          if (state is GetContractTemplatesLoading) {
            return CenterLoadingTextWidget(
              text: "Loading Contract Templates...",
            );
          }
          if (state is GetContractTemplatesSuccess) {
            if (state.templates.isEmpty) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CenterErrorWidget(error: "No Contract Templates found..."),
                  TextButton.icon(
                    onPressed: () {
                      context
                          .read<GetContractTemplatesCubit>()
                          .getTheContractTemplates();
                    },
                    label: Text("Refresh Templates"),
                    icon: Icon(Icons.refresh_outlined),
                  ),
                ],
              );
            }
            // Set initial template string if not already set
            if (_selectedId == null && state.templates.isNotEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                setState(() {
                  _selectedId = state.templates.first.id;
                  _currentTemplateString = state.templates.first.templateString;
                  debugPrint('Contract Template: ${state.templates.first.templateString}');
                });
              });
            }
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Select Template",
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          context
                              .read<GetContractTemplatesCubit>()
                              .getTheContractTemplates();
                        },
                        icon: const Icon(Icons.refresh),
                        tooltip: "Refresh Templates",
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  const GapV(12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      border: Border.all(
                        color: Colors.grey.shade200,
                        width: 1.5,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: DropdownButton<int>(
                      value: _selectedId,
                      isExpanded: true,
                      underline: const SizedBox(),
                      hint: Text(
                        "Choose a template",
                        style: TextStyle(color: Colors.grey.shade400),
                      ),
                      items: state.templates.map((template) {
                        return DropdownMenuItem<int>(
                          value: template.id,
                          child: Text(
                            template.title,
                            style: const TextStyle(color: Colors.black87),
                          ),
                        );
                      }).toList(),
                      onChanged: (int? newValue) {
                        if (newValue != null) {
                          setState(() {
                            _selectedId = newValue;
                            final selectedTemplate = state.templates.firstWhere(
                              (t) => t.id == newValue,
                            );
                            _currentTemplateString =
                                selectedTemplate.templateString;
                            debugPrint('Selected Template: ${selectedTemplate.templateString}');
                          });
                        }
                      },
                    ),
                  ),
                  const GapV(24),
                  Text(
                    "Preview",
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const GapV(12),
                  Expanded(
                    child: ContractPreview(
                      templateString: _currentTemplateString,
                    ),
                  ),
                  const GapV(32),
                  if (_isCreatingSubmission)
                    const Center(child: CircularProgressIndicator())
                  else
                    ButtonPrimary(
                      text: _selectedId != null &&
                              state.templates
                                  .any((t) => t.id == _selectedId && t.hasDocuSeal)
                          ? "Sign with DocuSeal"
                          : "Continue",
                      onPressed: () {
                        _submitForm(state.templates);
                      },
                    ),
                  const GapV(32),
                ],
              ),
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
