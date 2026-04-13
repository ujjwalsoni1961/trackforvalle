import 'dart:io';

import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/domain/entities/sign_contract_entity.dart';

abstract class ContractsRepository {
  ResultFuture<ContractTemplateListEntity> getContractTemplates();
  ResultFuture<SignContractEntity> submitContract({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File signature,
  });
  ResultFuture<SignContractEntity> submitContractPdf({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File contractPdf,
  });
  ResultFuture<Map<String, dynamic>> signContract({
    required int templateId,
    required int leadId,
    required Map<String, String> fieldValues,
    required String signatureBase64,
  });
}
