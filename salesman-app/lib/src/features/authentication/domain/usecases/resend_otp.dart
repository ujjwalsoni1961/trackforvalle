import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/repositories/resend_otp_repository.dart';

class ResendOTP extends UseCaseWithParams<void, ResendOtpParams> {
  final ResendOtpRepository _repository;

  ResendOTP(ResendOtpRepository repository) : _repository = repository;

  @override
  ResultFutureVoid call(ResendOtpParams params) async =>
      _repository.resendOtp(email: params.email, otpType: params.otpType);
}

class ResendOtpParams extends Equatable {
  final String email;
  final String otpType;

  const ResendOtpParams({required this.email, required this.otpType});

  @override
  List<Object?> get props => [email, otpType];
}
