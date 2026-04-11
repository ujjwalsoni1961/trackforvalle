part of 'verify_email_cubit.dart';

sealed class VerifyEmailState extends Equatable {
  const VerifyEmailState();

  @override
  List<Object> get props => [];
}

final class VerifyEmailInitial extends VerifyEmailState {}

// EMAIL VERIFICATION STATES

final class EmailVerifying extends VerifyEmailState {}

final class EmailVerified extends VerifyEmailState {
  const EmailVerified();

  @override
  List<Object> get props => [];
}

final class EmailVerificationFailed extends VerifyEmailState {
  final String errorMessage;

  const EmailVerificationFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
