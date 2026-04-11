import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/repositories/forgot_password_repository.dart';

class ForgotPassword extends UseCaseWithParams<void, ForgotPasswordParams> {
  final ForgetPasswordRepository _repository;

  ForgotPassword(ForgetPasswordRepository repository)
    : _repository = repository;

  @override
  ResultFutureVoid call(ForgotPasswordParams params) async =>
      _repository.forgotPassword(email: params.email);
}

class ForgotPasswordParams extends Equatable {
  final String email;

  const ForgotPasswordParams({required this.email});

  @override
  List<Object?> get props => [email];
}
