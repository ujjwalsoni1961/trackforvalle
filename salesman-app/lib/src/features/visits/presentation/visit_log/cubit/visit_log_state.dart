part of 'visit_log_cubit.dart';

sealed class VisitLogState extends Equatable {
  const VisitLogState();

  @override
  List<Object> get props => [];
}

final class VisitLogInitial extends VisitLogState {}

final class VisitLogLoading extends VisitLogState {}

final class VisitLogFailed extends VisitLogState {
  final String errorMessage;

  const VisitLogFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class VisitLogSuccess extends VisitLogState {
  final int leadID;
  final String leadStatus;

  const VisitLogSuccess({required this.leadID, required this.leadStatus});

  @override
  List<Object> get props => [leadID, leadStatus];
}
