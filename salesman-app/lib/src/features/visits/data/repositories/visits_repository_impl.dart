import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/data/data_sources/visits_remote_data_source.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_list_entity.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_list_entity.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';

class VisitsRepositoryImpl extends VisitsRepository {
  final VisitsRemoteDataSource _remoteDataSource;

  VisitsRepositoryImpl(VisitsRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;

  @override
  ResultFuture<DailyRoutesListEntity> getRoutes() async {
    try {
      final routes = await _remoteDataSource.getRoutes();
      return Right(routes);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<RefreshRouteListEntity> getUpdatedRoutes({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final updatedRoutes = await _remoteDataSource.getUpdatedRoutes(
        latitude: latitude,
        longitude: longitude,
      );
      return Right(updatedRoutes);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
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
  }) async {
    try {
      await _remoteDataSource.submitVisitLog(
        photos: photos,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        leadID: leadID,
        visitID: visitID,
        leadStatus: leadStatus,
        followUp: followUp,
        contractID: contractID,
      );
      return Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<PastVisitsListEntity> getPastVisits({
    String? leadStatus,
    int? leadID,
    int? limit,
    int? pageNumber,
  }) async {
    try {
      final pastVisits = await _remoteDataSource.getPastVisits(
        leadID: leadID,
        leadStatus: leadStatus,
        pageNumber: pageNumber,
        limit: limit,
      );
      return Right(pastVisits);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFutureVoid planVisits({
    required double latitude,
    required double longitude,
    required List<int> leadIds,
  }) async {
    try {
      await _remoteDataSource.planVisits(
        latitude: latitude,
        longitude: longitude,
        leadIds: leadIds,
      );
      return Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
