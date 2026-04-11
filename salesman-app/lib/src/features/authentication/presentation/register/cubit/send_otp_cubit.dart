import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/authentication/domain/usecases/resend_otp.dart';
part 'send_otp_state.dart';

class SendOtpCubit extends Cubit<SendOtpState> {
  final ResendOTP sendOtp;
  SendOtpCubit(this.sendOtp) : super(SendOtpInitial());

  void resendTheOtp(String email) async {
    emit(const SendingOTP());
    final response = await sendOtp(
      ResendOtpParams(email: email, otpType: 'EMAIL_VERIFICATION'),
    );
    response.fold((failure) => emit(OTPSendingFailed(failure.message)), (
      verifyOtpData,
    ) async {
      emit(const OTPSent());
    });
  }
}
