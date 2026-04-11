import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/dashboard/domain/entities/dashboard_entity.dart';

abstract class DashboardRepository {
  ResultFuture<DashboardDataEntity> getDashBoardData();
}
