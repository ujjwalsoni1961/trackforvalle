import 'package:equatable/equatable.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class PasswordVisibilityChanged extends RegisterState {
  final bool isPasswordVisible;

  const PasswordVisibilityChanged(this.isPasswordVisible);

  @override
  List<Object> get props => [isPasswordVisible];
}

final class ConfirmPasswordVisibilityChanged extends RegisterState {
  final bool isConfirmPasswordVisible;

  const ConfirmPasswordVisibilityChanged(this.isConfirmPasswordVisible);

  @override
  List<Object> get props => [isConfirmPasswordVisible];
}

final class Registering extends RegisterState {}

final class RegisterSuccess extends RegisterState {
  const RegisterSuccess();

  @override
  List<Object> get props => [];
}

final class RegisterFailed extends RegisterState {
  final String errorMessage;

  const RegisterFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
