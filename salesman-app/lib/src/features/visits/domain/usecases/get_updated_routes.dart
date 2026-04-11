import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_list_entity.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';

class GetUpdatedRoutes
    extends UseCaseWithParams<RefreshRouteListEntity, GetUpdatedRoutesParams> {
  final VisitsRepository _repository;

  GetUpdatedRoutes(VisitsRepository repository) : _repository = repository;

  @override
  ResultFuture<RefreshRouteListEntity> call(
    GetUpdatedRoutesParams params,
  ) async {
    return await _repository.getUpdatedRoutes(
      latitude: params.latitude,
      longitude: params.longitude,
    );
  }
}

class GetUpdatedRoutesParams extends Equatable {
  final double latitude;
  final double longitude;

  const GetUpdatedRoutesParams({
    required this.latitude,
    required this.longitude,
  });

  @override
  List<Object?> get props => [latitude, longitude];
}
