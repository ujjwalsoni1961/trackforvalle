import 'dart:io';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_list_entity.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_list_entity.dart';

abstract class VisitsRepository {
  ResultFuture<DailyRoutesListEntity> getRoutes();
  ResultFuture<RefreshRouteListEntity> getUpdatedRoutes({
    required double latitude,
    required double longitude,
  });
  ResultFutureVoid submitVisitLog({
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

  ResultFuture<PastVisitsListEntity> getPastVisits({
    String? leadStatus,
    int? leadID,
    int? limit,
    int? pageNumber,
  });

  ResultFutureVoid planVisits({
    required double latitude,
    required double longitude,
    required List<int> leadIds,
  });
}
