import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/features/authentication/domain/usecases/verify_otp.dart';
part 'verify_email_state.dart';

class VerifyEmailCubit extends Cubit<VerifyEmailState> {
  final VerifyOTP verifyEmail;

  VerifyEmailCubit(this.verifyEmail) : super(VerifyEmailInitial());
  int resendOtpTimeLeftInSeconds = 120;

  String formatDuration(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  void verifyEmailWithOtp({required String email, required String otp}) async {
    emit(EmailVerifying());
    if (email.isEmpty) {
      emit(const EmailVerificationFailed('Email is not set'));
      return;
    }
    final response = await verifyEmail(
      VerifyOTPParams(email: email, otp: otp, type: "EMAIL_VERIFICATION"),
    );
    response.fold((failure) => emit(EmailVerificationFailed(failure.message)), (
      _,
    ) async {
      final resLocalData = await sl<UserLocalDataSource>().updateUserData(
        isEmailVerified: true,
      );
      resLocalData.fold(
        (failure) => emit(EmailVerificationFailed(failure.message)),
        (_) => emit(const EmailVerified()),
      );
    });
  }
}
