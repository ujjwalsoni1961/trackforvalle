import 'dart:io';

import 'package:dio/dio.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/features/visits/data/models/daily_routes_list_model.dart';
import 'package:track/src/features/visits/data/models/past_visits_model.dart';
import 'package:track/src/features/visits/data/models/refresh_routes_list_model.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_list_entity.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_list_entity.dart';

abstract class VisitsRemoteDataSource {
  Future<DailyRoutesListEntity> getRoutes();
  Future<RefreshRouteListEntity> getUpdatedRoutes({
    required double latitude,
    required double longitude,
  });
  Future<void> submitVisitLog({
    required List<File> photos,
    required String notes,
    required double latitude,
    required double longitude,
    required int leadID,
    int? visitID,
    required String leadStatus,
    String? followUp,
    int? contractID,
  });

  Future<PastVisitsListEntity> getPastVisits({
    String? leadStatus,
    int? leadID,
    int? limit,
    int? pageNumber,
  });

  Future<void> planVisits({
    required double latitude,
    required double longitude,
    required List<int> leadIds,
  });
}

class VisitsRemoteDataSourceImpl extends VisitsRemoteDataSource {
  final API _api;

  VisitsRemoteDataSourceImpl(API api) : _api = api;

  @override
  Future<DailyRoutesListEntity> getRoutes() async {
    try {
      final response = await _api.dio.get('/visit/route/daily');
      if (response.statusCode == 200) {
        final data = List<Map<String, dynamic>>.from(response.data['data']);
        data.shuffle();
        return DailyRoutesListModel.fromMap(data);
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
  Future<RefreshRouteListEntity> getUpdatedRoutes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final response = await _api.dio.get(
        '/visit/route/refresh?latitude=$latitude&longitude=$longitude',
      );
      if (response.statusCode == 200) {
        final data = response.data['data'] as List<dynamic>?;
        if (data == null || data.isEmpty) {
          return RefreshRoutesListModel.fromMap([]);
        }
        return RefreshRoutesListModel.fromMap(
          data[0]['route_order'] ?? [],
        );
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
  Future<void> submitVisitLog({
    required List<File> photos,
    required String notes,
    required double latitude,
    required double longitude,
    required int leadID,
    int? visitID,
    required String leadStatus,
    String? followUp,
    int? contractID,
  }) async {
    try {
      Map<String, dynamic> requestBody = {
        'photos': photos
            .map(
              (file) => MultipartFile.fromBytes(
                file.readAsBytesSync(),
                filename: file.path,
              ),
            )
            .toList(),
        'notes': notes,
        'longitude': longitude,
        'latitude': latitude,
        'lead_id': leadID,
        'status': leadStatus,
        'followUps': followUp,
        'visit_id': visitID,
        'contract_id': contractID,
      };
      requestBody.removeWhere((key, value) => value == null);
      FormData formData = FormData.fromMap(requestBody);

      final response = await _api.dio.post('/visit/log', data: formData);
      if (response.statusCode == 200 || response.statusCode == 201) {
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
  Future<PastVisitsListEntity> getPastVisits({
    String? leadStatus,
    int? leadID,
    int? limit,
    int? pageNumber,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (leadStatus != null) queryParams['status'] = leadStatus;
      if (leadID != null) queryParams['lead_id'] = leadID;
      if (limit != null) queryParams['limit'] = limit;

      if (leadID == null) {
        queryParams['view'] = "past_visits";
      } else {
        queryParams['view'] = "history";
      }

      if (pageNumber != null) queryParams['page'] = pageNumber;

      final response = await _api.dio.get(
        '/visit/past-vists',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      if (response.statusCode == 200) {
        return PastVisitsListModel.fromMap(response.data);
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
  Future<void> planVisits({
    required double latitude,
    required double longitude,
    required List<int> leadIds,
  }) async {
    try {
      final response = await _api.dio.post(
        '/visit/plan',
        data: {
          "lead_ids": leadIds,
          "latitude": latitude,
          "longitude": longitude,
        },
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
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
}
