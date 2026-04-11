import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/dashboard/data/data_sources/dashboard_remote_data_source.dart';
import 'package:track/src/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:track/src/features/dashboard/domain/repositories/dashboard_repository.dart';

class DashboardRepositoryImpl extends DashboardRepository {
  final DashboardRemoteDataSource _remoteDataSource;
  DashboardRepositoryImpl(DashboardRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFuture<DashboardDataEntity> getDashBoardData() async {
    try {
      final dashboardData = await _remoteDataSource.getDashBoardData();
      return Right(dashboardData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
