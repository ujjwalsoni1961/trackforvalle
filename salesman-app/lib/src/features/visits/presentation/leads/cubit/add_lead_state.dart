part of 'add_lead_cubit.dart';

sealed class AddLeadState extends Equatable {
  const AddLeadState();

  @override
  List<Object> get props => [];
}

final class AddLeadInitial extends AddLeadState {}

final class AddLeadLoading extends AddLeadState {}

final class AddLeadSuccess extends AddLeadState {}

final class AddLeadFailed extends AddLeadState {
  final String errorMessage;

  const AddLeadFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
