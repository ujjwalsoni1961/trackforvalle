import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/domain/repositories/leads_repository.dart';

class GetLeadStatusList extends UseCaseWithoutParams<LeadStatusListEntity> {
  final LeadsRepository _repository;
  GetLeadStatusList(LeadsRepository repository) : _repository = repository;

  @override
  ResultFuture<LeadStatusListEntity> call() async =>
      await _repository.getLeadStatusList();
}
