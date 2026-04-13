import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/data/data_sources/contracts_remote_data_source.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/domain/entities/sign_contract_entity.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';

class ContractsRepositoryImpl extends ContractsRepository {
  final ContractsRemoteDataSource _remoteDataSource;

  ContractsRepositoryImpl(ContractsRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFuture<ContractTemplateListEntity> getContractTemplates() async {
    try {
      final templates = await _remoteDataSource.getContractTemplates();
      return Right(templates);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<SignContractEntity> submitContract({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File signature,
  }) async {
    try {
      final contract = await _remoteDataSource.submitContract(
        leadID: leadID,
        metaData: metaData,
        dropdownValues: dropdownValues,
        contractTemplateID: contractTemplateID,
        signature: signature,
      );
      return Right(contract);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<SignContractEntity> submitContractPdf({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File contractPdf,
  }) async {
    try {
      final contract = await _remoteDataSource.submitContractPdf(
        leadID: leadID,
        metaData: metaData,
        dropdownValues: dropdownValues,
        contractTemplateID: contractTemplateID,
        contractPdf: contractPdf,
      );
      return Right(contract);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<Map<String, dynamic>> signContract({
    required int templateId,
    required int leadId,
    required Map<String, String> fieldValues,
    required String signatureBase64,
  }) async {
    try {
      final result = await _remoteDataSource.signContract(
        templateId: templateId,
        leadId: leadId,
        fieldValues: fieldValues,
        signatureBase64: signatureBase64,
      );
      return Right(result);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
