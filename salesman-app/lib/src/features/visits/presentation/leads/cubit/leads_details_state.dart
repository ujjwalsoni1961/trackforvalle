part of 'leads_details_cubit.dart';

sealed class LeadsDetailsState extends Equatable {
  const LeadsDetailsState();

  @override
  List<Object> get props => [];
}

final class LeadsDetailsInitial extends LeadsDetailsState {}

final class LeadsDetailsLoading extends LeadsDetailsState {
  final bool isFirstPage;
  const LeadsDetailsLoading(this.isFirstPage);

  @override
  List<Object> get props => [isFirstPage];
}

final class LeadsDetailsLoaded extends LeadsDetailsState {
  final LeadsListEntity allLeads;

  const LeadsDetailsLoaded(this.allLeads);

  @override
  List<Object> get props => [allLeads];
}

final class LeadsDetailsFailed extends LeadsDetailsState {
  final String errorMessage;
  final int statusCode;

  const LeadsDetailsFailed(this.errorMessage, this.statusCode);

  @override
  List<Object> get props => [errorMessage, statusCode];
}
