part of 'lead_status_cubit.dart';

sealed class LeadStatusState extends Equatable {
  const LeadStatusState();

  @override
  List<Object> get props => [];
}

final class LeadStatusInitial extends LeadStatusState {}

final class LeadStatusLoading extends LeadStatusState {}

final class LeadStatusFailed extends LeadStatusState {
  final String errorMessage;

  const LeadStatusFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class LeadStatusSuccess extends LeadStatusState {
  final List<LeadStatusEntity> statusList;

  const LeadStatusSuccess(this.statusList);

  @override
  List<Object> get props => [statusList];
}
