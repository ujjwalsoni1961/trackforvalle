import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'verify_email_otp_timer_state.dart';

class VerifyEmailOtpTimerCubit extends Cubit<VerifyEmailOtpTimerState> {
  VerifyEmailOtpTimerCubit() : super(VerifyEmailOtpTimerInitial());
  Timer? timer;
  int seconds = 0;

  void startTimer() {
    stopTimer();
    seconds = 120;
    emit((TimerTicking(seconds)));
    timer = Timer.periodic(const Duration(seconds: 1), (currentTimer) {
      if (seconds <= 0) {
        stopTimer();
        return;
      }
      seconds--;
      emit((TimerTicking(seconds)));
    });
  }

  void stopTimer() async {
    seconds = 0;
    emit((TimerTicking(seconds)));
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
    await Future.delayed(const Duration(milliseconds: 100));
    emit(VerifyEmailOtpTimerInitial());
  }
}
