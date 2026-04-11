import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/contract_template_entity.dart';
import 'package:track/src/features/visits/domain/repositories/contracts_repository.dart';

class GetContractsTemplates
    extends UseCaseWithoutParams<ContractTemplateListEntity> {
  final ContractsRepository _repository;

  const GetContractsTemplates(ContractsRepository repository)
    : _repository = repository;
  @override
  ResultFuture<ContractTemplateListEntity> call() async =>
      await _repository.getContractTemplates();
}
