part of 'verify_email_otp_timer_cubit.dart';

sealed class VerifyEmailOtpTimerState extends Equatable {
  const VerifyEmailOtpTimerState();

  @override
  List<Object> get props => [];
}

final class VerifyEmailOtpTimerInitial extends VerifyEmailOtpTimerState {}

final class TimerTicking extends VerifyEmailOtpTimerState {
  final int seconds;
  const TimerTicking(this.seconds);
  @override
  List<Object> get props => [seconds];
}
