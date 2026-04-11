part of 'lead_id_past_visits_cubit.dart';

sealed class LeadIdPastVisitsState extends Equatable {
  const LeadIdPastVisitsState();

  @override
  List<Object> get props => [];
}

final class LeadIdPastVisitsInitial extends LeadIdPastVisitsState {}

final class LeadIDPastVisitsLoading extends LeadIdPastVisitsState {
  final bool isFirstPage;

  const LeadIDPastVisitsLoading(this.isFirstPage);

  @override
  List<Object> get props => [isFirstPage];
}

final class LeadIDPastVisitsSuccess extends LeadIdPastVisitsState {
  final List<PastVisitItemEntity> visits;
  final PaginationEntity pagination;

  const LeadIDPastVisitsSuccess(this.visits, this.pagination);

  @override
  List<Object> get props => [visits, pagination];
}

final class LeadIDPastVisitsFailed extends LeadIdPastVisitsState {
  final String errorMessage;

  const LeadIDPastVisitsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
