import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/sign_contract_entity.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';

class SubmitContract extends UseCaseWithParams<SignContractEntity, SubmitContractParams> {
  final ContractsRepository _repository;

  const SubmitContract(ContractsRepository repository)
    : _repository = repository;

  @override
  ResultFuture<SignContractEntity> call(SubmitContractParams params) async =>
      await _repository.submitContract(
        leadID: params.leadID,
        metaData: params.metaData,
        dropdownValues: params.dropdownValues,
        contractTemplateID: params.contractTemplateID,
        signature: params.signature,
      );
}

class SubmitContractParams extends Equatable {
  final int leadID;
  final int contractTemplateID;
  final Map<String, String> metaData;
  final Map<String, String> dropdownValues;
  final File signature;

  const SubmitContractParams({
    required this.leadID,
    required this.metaData,
    this.dropdownValues = const {},
    required this.contractTemplateID,
    required this.signature,
  });

  @override
  List<Object?> get props => [leadID, contractTemplateID, metaData, dropdownValues, signature];
}
