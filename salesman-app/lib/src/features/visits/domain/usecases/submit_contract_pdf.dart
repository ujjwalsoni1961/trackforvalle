import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/sign_contract_entity.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';

class SubmitContractPdf extends UseCaseWithParams<SignContractEntity, SubmitContractPdfParams> {
  final ContractsRepository _repository;

  const SubmitContractPdf(ContractsRepository repository)
    : _repository = repository;

  @override
  ResultFuture<SignContractEntity> call(SubmitContractPdfParams params) async =>
      await _repository.submitContractPdf(
        leadID: params.leadID,
        metaData: params.metaData,
        dropdownValues: params.dropdownValues,
        contractTemplateID: params.contractTemplateID,
        contractPdf: params.contractPdf,
      );
}

class SubmitContractPdfParams extends Equatable {
  final int leadID;
  final int contractTemplateID;
  final Map<String, String> metaData;
  final Map<String, String> dropdownValues;
  final File contractPdf;

  const SubmitContractPdfParams({
    required this.leadID,
    required this.metaData,
    this.dropdownValues = const {},
    required this.contractTemplateID,
    required this.contractPdf,
  });

  @override
  List<Object?> get props => [leadID, contractTemplateID, metaData, dropdownValues, contractPdf];
}