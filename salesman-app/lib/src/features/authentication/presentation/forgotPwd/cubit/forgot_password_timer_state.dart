part of 'forgot_password_timer_cubit.dart';

sealed class ForgotPasswordTimerState extends Equatable {
  const ForgotPasswordTimerState();

  @override
  List<Object> get props => [];
}

final class ForgotPasswordTimerInitial extends ForgotPasswordTimerState {}

final class TimerTicking extends ForgotPasswordTimerState {
  final int seconds;

  const TimerTicking(this.seconds);

  @override
  List<Object> get props => [seconds];
}
