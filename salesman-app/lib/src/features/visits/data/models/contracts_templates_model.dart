import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';

class ContractsTemplatesModel extends ContractTemplateEntity {
  const ContractsTemplatesModel({
    required super.id,
    required super.templateString,
    required super.title,
    super.dropdownFields,
    super.docusealTemplateId,
  });

  factory ContractsTemplatesModel.fromMap(DataMap map) {
    Map<String, DropdownField>? dropdownFields;
    
    if (map['dropdown_fields'] != null) {
      final dropdownData = map['dropdown_fields'] as Map<String, dynamic>;
      dropdownFields = {};
      
      dropdownData.forEach((key, value) {
        final fieldData = value as Map<String, dynamic>;
        final optionsData = fieldData['options'] as List<dynamic>;
        
        final options = optionsData.map((option) {
          final optionMap = option as Map<String, dynamic>;
          return DropdownOption(
            label: optionMap['label'] as String,
            value: optionMap['value'] as String,
          );
        }).toList();
        
        dropdownFields![key] = DropdownField(
          label: fieldData['label'] as String,
          options: options,
          required: fieldData['required'] as bool? ?? false,
          placeholder: fieldData['placeholder'] as String?,
        );
      });
    }
    
    return ContractsTemplatesModel(
      id: map['id'] as int,
      templateString: map['content'] as String,
      title: map['title'] as String,
      dropdownFields: dropdownFields,
      docusealTemplateId: map['docuseal_template_id'] as int?,
    );
  }
}

class ContractsTemplateListModel extends ContractTemplateListEntity {
  const ContractsTemplateListModel({required super.contracts});

  factory ContractsTemplateListModel.fromMap(List<dynamic> list) {
    return ContractsTemplateListModel(
      contracts: list
          .map(
            (item) =>
                ContractsTemplatesModel.fromMap(item as Map<String, dynamic>),
          )
          .toList(),
    );
  }
}
