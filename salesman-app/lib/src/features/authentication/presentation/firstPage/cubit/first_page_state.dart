part of 'first_page_cubit.dart';

sealed class FirstPageState extends Equatable {
  const FirstPageState();

  @override
  List<Object> get props => [];
}

final class FirstPageInitial extends FirstPageState {}

final class GoogleSigninInProgress extends FirstPageState {}

final class GoogleSigninSuccess extends FirstPageState {}

final class GoogleSigninFailure extends FirstPageState {
  final String errorMessage;
  const GoogleSigninFailure(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}

final class TermsAndConditionToggled extends FirstPageState {
  final bool isChecked;

  const TermsAndConditionToggled(this.isChecked);

  @override
  List<Object> get props => [isChecked];
}
