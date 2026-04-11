import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/features/visits/data/models/lead_status_model.dart';
import 'package:track/src/features/visits/data/models/leads_list_model.dart';
import 'package:track/src/features/visits/data/models/leads_model.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_list_entity.dart';

abstract class LeadsRemoteDataSource {
  Future<LeadsListEntity> getLeads({
    required int pageNumber,
    required int limit,
    String? query,
  });
  Future<LeadsDetailsEntity> updateLeadDetails({
    required int leadID,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? streetAddress,
    String? postalCode,
    String? areaName,
    String? subregion,
    String? region,
    String? country,
    String? status,
  });

  Future<void> addLead({
    required String name,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
    required String streetAddress,
    required String city,
    required String state,
    required String postalCode,
    required String areaName,
    required String subregion,
    required String region,
    required String country,
  });
  Future<LeadStatusListEntity> getLeadStatusList();
}

class LeadsRemoteDataSourceImpl extends LeadsRemoteDataSource {
  final API _api;

  LeadsRemoteDataSourceImpl(API api) : _api = api;

  @override
  Future<LeadsListEntity> getLeads({
    required int pageNumber,
    required int limit,
    String? query,
  }) async {
    try {
      final response = await _api.dio.get(
        '/leads/?page=$pageNumber&limit=$limit${query != null ? "&search=$query" : ""}',
      );
      if (response.statusCode == 200) {
        return LeadsListModel.fromMap(response.data['data']);
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
  Future<LeadsDetailsEntity> updateLeadDetails({
    required int leadID,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? streetAddress,
    String? postalCode,
    String? areaName,
    String? subregion,
    String? region,
    String? country,
    String? status,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        'org_id': null,
        'contact_name': contactName,
        'contact_email': contactEmail,
        'contact_phone': contactPhone,
        'street_address': streetAddress,
        'postal_code': postalCode,
        'area_name': areaName,
        'subregion': subregion,
        'region': region,
        'country': country,
        'status': status,
      };
      requestBody.removeWhere((key, value) => value == null);

      final response = await _api.dio.patch(
        '/leads/$leadID',
        data: requestBody,
      );
      if (response.statusCode == 200) {
        return LeadsDetailsModel.fromMap(response.data['data']);
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
  Future<void> addLead({
    required String name,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
    required String streetAddress,
    required String city,
    required String state,
    required String postalCode,
    required String areaName,
    required String subregion,
    required String region,
    required String country,
  }) async {
    try {
      final Map<String, dynamic> requestBody = {
        "name": name,
        "contact_name": contactName,
        "contact_email": contactEmail,
        "contact_phone": contactPhone,
        "street_address": streetAddress,
        "city": city,
        "state": state,
        "postal_code": postalCode,
        "area_name": areaName,
        "subregion": subregion,
        "region": region,
        "country": country,
      };
      requestBody.removeWhere((key, value) => value == null);

      final response = await _api.dio.post('/leads/', data: requestBody);
      if (response.statusCode == 201 || response.statusCode == 200) {
        return;
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
  Future<LeadStatusListEntity> getLeadStatusList() async {
    try {
      final response = await _api.dio.get('/user/lead-status');
      if (response.statusCode == 200) {
        return LeadStatusListModel.fromMap(response.data['data']);
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
