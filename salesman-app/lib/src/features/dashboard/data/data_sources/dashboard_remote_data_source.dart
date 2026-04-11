import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/features/dashboard/data/models/dashboard_model.dart';
import 'package:track/src/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRemoteDataSource {
  Future<DashboardDataEntity> getDashBoardData();
}

class DashboardRemoteDataSourceImpl extends DashboardRemoteDataSource {
  final API _api;
  DashboardRemoteDataSourceImpl(API api) : _api = api;

  @override
  Future<DashboardDataEntity> getDashBoardData() async {
    try {
      final response = await _api.dio.get('/dashboard');
      if (response.statusCode == 200) {
        return DashboardDataModel.fromMap(response.data['data']);
      } else {
        throw APIException(
          message: response.data['error']['message'],
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e is APIException ? e.message : e.runtimeType.toString(),
        statusCode: 505,
      );
    }
  }
}
