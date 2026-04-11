import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/authentication/domain/usecases/forgot_password.dart';
part 'forgot_password_state.dart';

class ForgotPasswordCubit extends Cubit<ForgotPasswordState> {
  final ForgotPassword forgotPassword;
  ForgotPasswordCubit(this.forgotPassword) : super(ForgotPasswordInitial());

  void sendForgotPasswordOtp(String email, bool isResendOTP) async {
    emit(SendingOTP());
    final response = await forgotPassword(ForgotPasswordParams(email: email));

    response.fold((failure) => emit(OTPSendingFailed(failure.message)), (
      forgotPasswordData,
    ) {
      emit(const OTPSent());
    });
  }
}
