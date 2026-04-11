part of 'past_visits_cubit.dart';

sealed class PastVisitsState extends Equatable {
  const PastVisitsState();

  @override
  List<Object> get props => [];
}

final class PastVisitsInitial extends PastVisitsState {}

final class PastVisitsLoading extends PastVisitsState {
  final bool isFirstPage;

  const PastVisitsLoading(this.isFirstPage);

  @override
  List<Object> get props => [isFirstPage];
}

final class PastVisitsSuccess extends PastVisitsState {
  final List<PastVisitItemEntity> visits;
  final PaginationEntity pagination;

  const PastVisitsSuccess(this.visits, this.pagination);

  @override
  List<Object> get props => [visits, pagination];
}

final class PastVisitsFailed extends PastVisitsState {
  final String errorMessage;

  const PastVisitsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
