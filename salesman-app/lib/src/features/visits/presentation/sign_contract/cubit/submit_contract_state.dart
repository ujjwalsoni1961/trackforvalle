part of 'submit_contract_cubit.dart';

sealed class SubmitContractState extends Equatable {
  const SubmitContractState();

  @override
  List<Object> get props => [];
}

final class SubmitContractInitial extends SubmitContractState {}

final class SubmitContractLoading extends SubmitContractState {}

final class SubmitContractSuccess extends SubmitContractState {
  final int contractID;
  final int visitID;

  const SubmitContractSuccess({
    required this.contractID,
    required this.visitID,
  });

  @override
  List<Object> get props => [contractID, visitID];
}

final class SubmitContractFailed extends SubmitContractState {
  final String errorMessage;

  const SubmitContractFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
