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
  
  const SignContractViewPageParams({
    required this.contractTemplateID,
    required this.leadID,
    required this.fields,
    required this.templateString,
    this.dropdownFields,
  });

  @override
  List<Object?> get props => [
    contractTemplateID,
    leadID,
    fields,
    templateString,
    dropdownFields,
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
    
    // Initialize dropdown values
    if (widget.params.dropdownFields != null) {
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
      // Validate required dropdown fields
      if (widget.params.dropdownFields != null) {
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
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
                  itemCount: widget.params.fields.length + 
                    (widget.params.dropdownFields?.length ?? 0),
                  padding: EdgeInsets.only(top: 8),
                  separatorBuilder: (_, __) => const GapV(16),
                  itemBuilder: (context, index) {
                    final totalTextFields = widget.params.fields.length;
                    
                    // Show text fields first
                    if (index < totalTextFields) {
                      final field = widget.params.fields[index];
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
                            return '$field is required';
                          }
                          return null;
                        },
                      );
                    }
                    
                    // Show dropdown fields after text fields
                    else if (widget.params.dropdownFields != null) {
                      final dropdownIndex = index - totalTextFields;
                      final dropdownKeys = widget.params.dropdownFields!.keys.toList();
                      
                      if (dropdownIndex >= 0 && dropdownIndex < dropdownKeys.length) {
                        final fieldKey = dropdownKeys[dropdownIndex];
                        final dropdownField = widget.params.dropdownFields![fieldKey]!;
                        
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              dropdownField.label + (dropdownField.required ? ' *' : ''),
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
                                  dropdownField.placeholder ?? 'Select ${dropdownField.label}',
                                  style: TextStyle(color: Colors.grey.shade400),
                                ),
                                items: dropdownField.options.map((option) {
                                  return DropdownMenuItem<String>(
                                    value: option.value,
                                    child: Text(
                                      option.label,
                                      style: const TextStyle(color: Colors.black87),
                                    ),
                                  );
                                }).toList(),
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
