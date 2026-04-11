import 'dart:async';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

part 'forgot_password_timer_state.dart';

class ForgotPasswordTimerCubit extends Cubit<ForgotPasswordTimerState> {
  ForgotPasswordTimerCubit() : super(ForgotPasswordTimerInitial());
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
    if (timer != null) {
      timer!.cancel();
      timer = null;
    } else {
      return;
    }
    seconds = 0;
    emit(ForgotPasswordTimerInitial());
  }
}
