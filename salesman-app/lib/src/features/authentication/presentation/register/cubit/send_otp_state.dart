part of 'send_otp_cubit.dart';

sealed class SendOtpState extends Equatable {
  const SendOtpState();

  @override
  List<Object> get props => [];
}

final class SendOtpInitial extends SendOtpState {}

final class SendingOTP extends SendOtpState {
  const SendingOTP();

  @override
  List<Object> get props => [];
}

final class OTPSent extends SendOtpState {
  const OTPSent();

  @override
  List<Object> get props => [];
}

final class OTPSendingFailed extends SendOtpState {
  final String errorMessage;

  const OTPSendingFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
