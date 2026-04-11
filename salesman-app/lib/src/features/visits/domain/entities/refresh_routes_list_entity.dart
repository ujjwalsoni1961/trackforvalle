import 'package:equatable/equatable.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_entity.dart';

class RefreshRouteListEntity extends Equatable {
  final List<RefreshRoutesEntity> updatedRoutes;

  const RefreshRouteListEntity({required this.updatedRoutes});

  @override
  List<Object?> get props => [updatedRoutes];
}
