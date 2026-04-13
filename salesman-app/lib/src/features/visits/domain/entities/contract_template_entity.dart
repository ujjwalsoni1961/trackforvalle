import 'package:equatable/equatable.dart';

class DropdownOption extends Equatable {
  final String label;
  final String value;

  const DropdownOption({
    required this.label,
    required this.value,
  });

  @override
  List<Object?> get props => [label, value];
}

class DropdownField extends Equatable {
  final String label;
  final List<DropdownOption> options;
  final bool required;
  final String? placeholder;

  const DropdownField({
    required this.label,
    required this.options,
    this.required = false,
    this.placeholder,
  });

  @override
  List<Object?> get props => [label, options, required, placeholder];
}

class ContractTemplateEntity extends Equatable {
  final int id;
  final String templateString;
  final String title;
  final Map<String, DropdownField>? dropdownFields;
  final String templateType;
  final String? pdfUrl;
  final List<Map<String, dynamic>>? fieldPositions;

  const ContractTemplateEntity({
    required this.id,
    required this.title,
    required this.templateString,
    this.dropdownFields,
    this.templateType = 'richtext',
    this.pdfUrl,
    this.fieldPositions,
  });

  bool get isPdfUpload => templateType == 'pdf_upload';

  @override
  List<Object?> get props => [id, title, templateString, dropdownFields, templateType, pdfUrl, fieldPositions];
}

class ContractTemplateListEntity extends Equatable {
  final List<ContractTemplateEntity> contracts;

  const ContractTemplateListEntity({required this.contracts});

  @override
  List<Object?> get props => [contracts];
}
