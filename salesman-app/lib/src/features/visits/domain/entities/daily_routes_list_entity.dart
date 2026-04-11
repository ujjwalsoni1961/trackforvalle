import 'package:equatable/equatable.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_entity.dart';

class DailyRoutesListEntity extends Equatable {
  final List<DailyRoutesEntity> routes;

  const DailyRoutesListEntity({required this.routes});

  @override
  List<Object?> get props => [routes];
}
