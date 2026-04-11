part of 'plan_visits_cubit.dart';

sealed class PlanVisitsState extends Equatable {
  const PlanVisitsState();

  @override
  List<Object> get props => [];
}

final class PlanVisitsInitial extends PlanVisitsState {}

final class PlanVisitsLoading extends PlanVisitsState {}

final class PlanVisitsFailed extends PlanVisitsState {
  final String errorMessage;

  const PlanVisitsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class PlanVisitsSuccess extends PlanVisitsState {}
