import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/leads_list_entity.dart';
import 'package:track/src/features/visits/domain/repositories/leads_repository.dart';

class GetAllLeads
    extends UseCaseWithParams<LeadsListEntity, GetAllLeadsParams> {
  final LeadsRepository _repository;

  GetAllLeads(LeadsRepository repository) : _repository = repository;

  @override
  ResultFuture<LeadsListEntity> call(GetAllLeadsParams params) async {
    return await _repository.getLeads(
      pageNumber: params.pageNumber,
      limit: params.limit,
      query: params.query,
    );
  }
}

class GetAllLeadsParams extends Equatable {
  final int pageNumber;
  final int limit;
  final String? query;

  const GetAllLeadsParams({
    required this.pageNumber,
    required this.limit,
    this.query,
  });

  @override
  List<Object?> get props => [pageNumber, limit, query];
}
