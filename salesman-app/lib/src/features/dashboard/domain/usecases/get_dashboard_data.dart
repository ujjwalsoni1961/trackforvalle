import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:track/src/features/dashboard/domain/repositories/dashboard_repository.dart';

class GetDashboardData extends UseCaseWithoutParams<DashboardDataEntity> {
  final DashboardRepository _repository;
  const GetDashboardData(DashboardRepository repository)
    : _repository = repository;
  @override
  ResultFuture<DashboardDataEntity> call() async =>
      await _repository.getDashBoardData();
}
