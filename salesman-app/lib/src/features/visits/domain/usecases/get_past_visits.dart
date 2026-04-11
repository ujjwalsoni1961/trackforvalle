import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';

class GetPastVisits
    extends UseCaseWithParams<PastVisitsListEntity, PastVisitsParams> {
  final VisitsRepository _repository;

  const GetPastVisits(VisitsRepository repository) : _repository = repository;
  @override
  ResultFuture<PastVisitsListEntity> call(PastVisitsParams params) async =>
      await _repository.getPastVisits(
        leadID: params.leadID,
        leadStatus: params.leadStatus,
        pageNumber: params.pageNumber,
        limit: params.limit,
      );
}

class PastVisitsParams extends Equatable {
  final String? leadStatus;
  final int? leadID;
  final int? pageNumber;
  final int? limit;

  const PastVisitsParams({
    this.leadStatus,
    this.leadID,
    this.limit,
    this.pageNumber,
  });

  @override
  List<Object?> get props => [leadStatus, leadID, limit, pageNumber];
}
