part of 'forgot_password_cubit.dart';

sealed class ForgotPasswordState extends Equatable {
  const ForgotPasswordState();

  @override
  List<Object> get props => [];
}

final class ForgotPasswordInitial extends ForgotPasswordState {}

// OTP STATES

final class SendingOTP extends ForgotPasswordState {}

final class OTPSent extends ForgotPasswordState {
  const OTPSent();

  @override
  List<Object> get props => [];
}

final class OTPSendingFailed extends ForgotPasswordState {
  final String errorMessage;
  const OTPSendingFailed(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}
