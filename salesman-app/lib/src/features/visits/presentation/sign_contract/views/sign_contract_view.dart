import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/presentation/sign_contract/widgets/sign_contract_preview_modal.dart';

class SignContractViewPageParams extends Equatable {
  final int contractTemplateID;
  final int leadID;
  final List<String> fields;
  final String templateString;
  final Map<String, DropdownField>? dropdownFields;
  final String templateType;
  final String? pdfUrl;
  final List<Map<String, dynamic>>? fieldPositions;
  
  const SignContractViewPageParams({
    required this.contractTemplateID,
    required this.leadID,
    required this.fields,
    required this.templateString,
    this.dropdownFields,
    this.templateType = 'richtext',
    this.pdfUrl,
    this.fieldPositions,
  });

  bool get isPdfUpload => templateType == 'pdf_upload';

  @override
  List<Object?> get props => [
    contractTemplateID,
    leadID,
    fields,
    templateString,
    dropdownFields,
    templateType,
    pdfUrl,
    fieldPositions,
  ];
}

class SignContractView extends StatefulWidget {
  final SignContractViewPageParams params;
  const SignContractView({super.key, required this.params});

  @override
  State<SignContractView> createState() => _SignContractViewState();
}

class _SignContractViewState extends State<SignContractView> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, String?> _dropdownValues = {};
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    
    // Initialize text controllers for regular fields
    for (var field in widget.params.fields) {
      _controllers[field] = TextEditingController();
    }
    
    // Initialize dropdown values — from richtext dropdown fields OR pdf_upload dropdown field positions
    if (widget.params.isPdfUpload) {
      // For PDF uploads, dropdown options come from fieldPositions
      final dropdownPositions = (widget.params.fieldPositions ?? [])
          .where((f) => f['type'] == 'dropdown');
      for (var dp in dropdownPositions) {
        final label = (dp['label'] as String? ?? dp['id'] as String? ?? '').toLowerCase();
        if (label.isNotEmpty) {
          _dropdownValues[label] = null;
        }
      }
    } else if (widget.params.dropdownFields != null) {
      for (var key in widget.params.dropdownFields!.keys) {
        _dropdownValues[key] = null;
      }
    }
  }

  @override
  void dispose() {
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  String snakeToTitleCase(String text) {
    return text
        .split('_')
        .map((word) {
          if (word.isEmpty) return '';
          return word[0].toUpperCase() + word.substring(1);
        })
        .join(' ');
  }

  void _submitContract() {
    if (_formKey.currentState!.validate()) {
      // Validate required dropdown fields (richtext mode)
      if (!widget.params.isPdfUpload && widget.params.dropdownFields != null) {
        for (var entry in widget.params.dropdownFields!.entries) {
          if (entry.value.required && (_dropdownValues[entry.key] == null || _dropdownValues[entry.key]!.isEmpty)) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${entry.value.label} is required')),
            );
            return;
          }
        }
      }

      final Map<String, String> formData = {};
      
      // Add text field values
      _controllers.forEach((field, controller) {
        formData[field] = controller.text.trim();
      });
      
      // Add dropdown values
      _dropdownValues.forEach((field, value) {
        if (value != null) {
          formData[field] = value;
        }
      });

      // Show modal with preview and signature pad
      showDialog(
        context: context,
        builder: (context) => ContractPreviewModal(
          templateString: widget.params.templateString,
          formData: formData,
          dropdownValues: {
            for (var entry in _dropdownValues.entries)
              if (entry.value != null) entry.key: entry.value!
          },
          leadID: widget.params.leadID,
          contractTemplateID: widget.params.contractTemplateID,
          pdfUrl: widget.params.pdfUrl,
        ),
      );
    }
  }

  /// Build dropdown items for a PDF field position
  List<DropdownMenuItem<String>> _buildPdfDropdownItems(Map<String, dynamic> fieldPos) {
    final options = fieldPos['options'] as List<dynamic>? ?? [];
    return options.map((opt) {
      final s = opt.toString();
      return DropdownMenuItem<String>(value: s, child: Text(s, style: const TextStyle(color: Colors.black87)));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    // Determine the list of form items to show
    final textFields = widget.params.fields
        .where((f) => !_dropdownValues.containsKey(f))
        .toList();

    return MyScaffold(
      title: "Sign Contract",
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ListView.separated(
                  itemCount: textFields.length + _dropdownValues.length,
                  padding: EdgeInsets.only(top: 8),
                  separatorBuilder: (_, __) => const GapV(16),
                  itemBuilder: (context, index) {
                    // Show text fields first
                    if (index < textFields.length) {
                      final field = textFields[index];
                      return TextFormField(
                        controller: _controllers[field],
                        decoration: InputDecoration(
                          labelText: snakeToTitleCase(field),
                          labelStyle: TextStyle(color: Colors.grey.shade600),
                          hintText: 'Enter ${snakeToTitleCase(field)}...',
                          hintStyle: TextStyle(color: Colors.grey.shade400),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.grey.shade200),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.blue.shade300,
                              width: 1.5,
                            ),
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(color: Colors.red.shade300),
                          ),
                          focusedErrorBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.red.shade300,
                              width: 1.5,
                            ),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return '${snakeToTitleCase(field)} is required';
                          }
                          return null;
                        },
                      );
                    }
                    
                    // Show dropdown fields after text fields
                    final dropdownIndex = index - textFields.length;
                    final dropdownKeys = _dropdownValues.keys.toList();
                    
                    if (dropdownIndex >= 0 && dropdownIndex < dropdownKeys.length) {
                      final fieldKey = dropdownKeys[dropdownIndex];
                      
                      // Determine label and items based on template type
                      String displayLabel;
                      List<DropdownMenuItem<String>> items;
                      bool isRequired;
                      String? placeholder;

                      if (widget.params.isPdfUpload) {
                        // PDF upload: get options from fieldPositions
                        final fieldPos = (widget.params.fieldPositions ?? []).firstWhere(
                          (f) => (f['label'] as String? ?? f['id'] as String? ?? '').toLowerCase() == fieldKey,
                          orElse: () => <String, dynamic>{},
                        );
                        displayLabel = snakeToTitleCase(fieldKey);
                        items = _buildPdfDropdownItems(fieldPos);
                        isRequired = fieldPos['required'] == true;
                        placeholder = 'Select $displayLabel';
                      } else {
                        // Richtext: get from dropdownFields map
                        final dropdownField = widget.params.dropdownFields![fieldKey]!;
                        displayLabel = dropdownField.label;
                        isRequired = dropdownField.required;
                        placeholder = dropdownField.placeholder ?? 'Select ${dropdownField.label}';
                        items = dropdownField.options.map((option) {
                          return DropdownMenuItem<String>(
                            value: option.value,
                            child: Text(option.label, style: const TextStyle(color: Colors.black87)),
                          );
                        }).toList();
                      }
                      
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayLabel + (isRequired ? ' *' : ''),
                            style: TextStyle(
                              color: Colors.grey.shade700,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const GapV(8),
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
                            child: DropdownButton<String>(
                              value: _dropdownValues[fieldKey],
                              isExpanded: true,
                              underline: const SizedBox(),
                              hint: Text(
                                placeholder ?? 'Select...',
                                style: TextStyle(color: Colors.grey.shade400),
                              ),
                              items: items,
                              onChanged: (String? newValue) {
                                setState(() {
                                  _dropdownValues[fieldKey] = newValue;
                                });
                              },
                            ),
                          ),
                        ],
                      );
                    }
                    
                    return const SizedBox.shrink();
                  },
                ),
              ),
              const GapV(16),
              ButtonPrimary(text: "Continue", onPressed: _submitContract),
              const GapV(16),
            ],
          ),
        ),
      ),
    );
  }
}
