part of 'login_cubit.dart';

sealed class LoginState extends Equatable {
  const LoginState();

  @override
  List<Object> get props => [];
}

final class LoginInitial extends LoginState {}

final class LoggingIn extends LoginState {}

final class LoginSuccess extends LoginState {
  final UserEntity userData;
  const LoginSuccess(this.userData);
  @override
  List<Object> get props => [userData];
}

final class LoginFailed extends LoginState {
  final String errorMessage;
  const LoginFailed(this.errorMessage);
  @override
  List<Object> get props => [errorMessage];
}

final class PasswordVisibilityChanged extends LoginState {
  final bool isPasswordVisible;
  const PasswordVisibilityChanged(this.isPasswordVisible);
  @override
  List<Object> get props => [isPasswordVisible];
}
