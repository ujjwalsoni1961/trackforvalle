import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/repositories/login_repository.dart';

class LoginWithGoogle
    extends UseCaseWithParams<UserEntity, LoginWithGoogleParams> {
  final LoginRepository _repository;

  LoginWithGoogle(LoginRepository repository) : _repository = repository;

  @override
  ResultFuture<UserEntity> call(LoginWithGoogleParams params) async =>
      _repository.loginWithGoogle(googleAccessToken: params.googleAccessToken);
}

class LoginWithGoogleParams extends Equatable {
  final String googleAccessToken;

  const LoginWithGoogleParams({required this.googleAccessToken});

  @override
  List<Object?> get props => [googleAccessToken];
}
