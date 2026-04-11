part of 'edit_a_lead_details_cubit.dart';

sealed class EditALeadDetailsState extends Equatable {
  const EditALeadDetailsState();

  @override
  List<Object> get props => [];
}

final class EditALeadDetailsInitial extends EditALeadDetailsState {}

final class EditALeadDetailsLoading extends EditALeadDetailsState {}

final class EditALeadDetailsFailed extends EditALeadDetailsState {
  final String errorMessage;

  const EditALeadDetailsFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class EditALeadDetailsSuccess extends EditALeadDetailsState {
  final LeadsDetailsEntity leadDetails;

  const EditALeadDetailsSuccess(this.leadDetails);

  @override
  List<Object> get props => [leadDetails];
}
