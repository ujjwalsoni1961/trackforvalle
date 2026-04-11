import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/repositories/login_repository.dart';

class LoginWithCredentials
    extends UseCaseWithParams<UserEntity, LoginWithCredentialsParams> {
  final LoginRepository _repository;

  LoginWithCredentials(LoginRepository repository) : _repository = repository;

  @override
  ResultFuture<UserEntity> call(LoginWithCredentialsParams params) async =>
      _repository.loginWithCredentials(
        email: params.email,
        password: params.password,
      );
}

class LoginWithCredentialsParams extends Equatable {
  final String email;
  final String password;

  const LoginWithCredentialsParams({
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [email, password];
}
