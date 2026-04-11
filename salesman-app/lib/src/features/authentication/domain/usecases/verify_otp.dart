import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/repositories/verify_otp_repository.dart';

class VerifyOTP extends UseCaseWithParams<void, VerifyOTPParams> {
  final VerifyOTPRepository _repository;

  VerifyOTP(VerifyOTPRepository repository) : _repository = repository;

  @override
  ResultFutureVoid call(VerifyOTPParams params) async => _repository
      .verifyEmail(email: params.email, otp: params.otp, type: params.type);
}

class VerifyOTPParams extends Equatable {
  final String otp;
  final String email;
  final String type;

  const VerifyOTPParams({
    required this.email,
    required this.otp,
    required this.type,
  });

  @override
  List<Object?> get props => [email, otp, type];
}
