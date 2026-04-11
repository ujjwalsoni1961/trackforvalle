import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/features/visits/data/models/contracts_templates_model.dart';
import 'package:track/src/features/visits/data/models/sign_contract_model.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/domain/entities/sign_contract_entity.dart';

abstract class ContractsRemoteDataSource {
  Future<ContractTemplateListEntity> getContractTemplates();
  Future<SignContractEntity> submitContract({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File signature,
  });
  Future<SignContractEntity> submitContractPdf({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File contractPdf,
  });
}

class ContractsRemoteDataSourceImpl extends ContractsRemoteDataSource {
  final API _api;

  ContractsRemoteDataSourceImpl(this._api);

  @override
  Future<ContractTemplateListEntity> getContractTemplates() async {
    try {
      final response = await _api.dio.get('/contract/templates');
      if (response.statusCode == 200) {
        return ContractsTemplateListModel.fromMap(response.data['data']);
      } else {
        throw APIException(
          message: response.data?['error']?['message']?.toString() ?? 'Request failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e.toString(),
        statusCode: 505,
      );
    }
  }

  @override
  Future<SignContractEntity> submitContract({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File signature,
  }) async {
    try {
      Map<String, dynamic> data = {
        'signature': MultipartFile.fromBytes(
          signature.readAsBytesSync(),
          filename: signature.path,
        ),
        "lead_id": leadID,
        "contract_template_id": contractTemplateID,
        "metadata": jsonEncode(metaData),
        if (dropdownValues.isNotEmpty) "dropdownValues": jsonEncode(dropdownValues),
      };
      data.removeWhere((key, value) => value == null);

      FormData formData = FormData.fromMap(data);

      final response = await _api.dio.post('/contract/submit', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignContractModel.fromMap(response.data['data']);
      } else {
        throw APIException(
          message: response.data?['error']?['message']?.toString() ?? 'Request failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e.toString(),
        statusCode: 505,
      );
    }
  }

  @override
  Future<SignContractEntity> submitContractPdf({
    required int leadID,
    required Map<String, String> metaData,
    Map<String, String> dropdownValues = const {},
    required int contractTemplateID,
    required File contractPdf,
  }) async {
    try {
      Map<String, dynamic> data = {
        'contract_pdf': MultipartFile.fromBytes(
          contractPdf.readAsBytesSync(),
          filename: 'contract_${DateTime.now().millisecondsSinceEpoch}.pdf',
          contentType: MediaType('application', 'pdf'),
        ),
        "lead_id": leadID,
        "contract_template_id": contractTemplateID,
        "metadata": jsonEncode(metaData),
        if (dropdownValues.isNotEmpty) "dropdownValues": jsonEncode(dropdownValues),
      };
      data.removeWhere((key, value) => value == null);

      FormData formData = FormData.fromMap(data);

      final response = await _api.dio.post('/contract/submit-pdf', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
        return SignContractModel.fromMap(response.data['data']);
      } else {
        throw APIException(
          message: response.data?['error']?['message']?.toString() ?? 'Request failed',
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e.toString(),
        statusCode: 505,
      );
    }
  }
}
