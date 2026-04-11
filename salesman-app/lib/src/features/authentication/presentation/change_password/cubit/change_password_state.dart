part of 'change_password_cubit.dart';

sealed class ChangePasswordState extends Equatable {
  const ChangePasswordState();

  @override
  List<Object> get props => [];
}

final class ChangePasswordInitial extends ChangePasswordState {}

final class OldPasswordVisibliityChanged extends ChangePasswordState {
  final bool isVisible;

  const OldPasswordVisibliityChanged(this.isVisible);

  @override
  List<Object> get props => [isVisible];
}

final class NewPasswordVisibliityChanged extends ChangePasswordState {
  final bool isVisible;

  const NewPasswordVisibliityChanged(this.isVisible);

  @override
  List<Object> get props => [isVisible];
}

final class ConfirmPasswordVisiblityChanged extends ChangePasswordState {
  final bool isVisible;

  const ConfirmPasswordVisiblityChanged(this.isVisible);

  @override
  List<Object> get props => [isVisible];
}

final class ChangingPassword extends ChangePasswordState {}

final class ChangePasswordSuccess extends ChangePasswordState {}

final class ChangePasswordFailed extends ChangePasswordState {
  final String errorMessage;

  const ChangePasswordFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
