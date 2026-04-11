part of 'get_contract_templates_cubit.dart';

sealed class GetContractTemplatesState extends Equatable {
  const GetContractTemplatesState();

  @override
  List<Object> get props => [];
}

final class GetContractTemplatesInitial extends GetContractTemplatesState {}

final class GetContractTemplatesFailed extends GetContractTemplatesState {
  final String errorMessage;

  const GetContractTemplatesFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class GetContractTemplatesLoading extends GetContractTemplatesState {}

final class GetContractTemplatesSuccess extends GetContractTemplatesState {
  final List<ContractTemplateEntity> templates;

  const GetContractTemplatesSuccess(this.templates);

  @override
  List<Object> get props => [templates];
}
