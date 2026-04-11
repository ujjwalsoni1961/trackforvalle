import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';

class PlanVisits extends UseCaseWithParams<void, PlanVisitsParams> {
  final VisitsRepository _repository;
  const PlanVisits(VisitsRepository repository) : _repository = repository;
  @override
  ResultFutureVoid call(PlanVisitsParams params) async =>
      await _repository.planVisits(
        leadIds: params.leadIds,
        latitude: params.latitude,
        longitude: params.longitude,
      );
}

class PlanVisitsParams extends Equatable {
  final double latitude;
  final double longitude;
  final List<int> leadIds;

  const PlanVisitsParams({
    required this.latitude,
    required this.longitude,
    required this.leadIds,
  });

  @override
  List<Object?> get props => [latitude, latitude, leadIds];
}
