import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/authentication/domain/usecases/change_password.dart';

part 'change_password_state.dart';

class ChangePasswordCubit extends Cubit<ChangePasswordState> {
  final ChangePassword changePassword;
  ChangePasswordCubit(this.changePassword) : super(ChangePasswordInitial());

  void dispose() {
    emit(ChangePasswordInitial());
  }

  bool isOldPasswordVisible = false;
  bool isNewPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void toggleOldPasswordVisibility() {
    isOldPasswordVisible = !isOldPasswordVisible;
    emit(OldPasswordVisibliityChanged(isOldPasswordVisible));
  }

  void toggleNewPasswordVisibility() {
    isNewPasswordVisible = !isNewPasswordVisible;
    emit(NewPasswordVisibliityChanged(isNewPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    emit(ConfirmPasswordVisiblityChanged(isConfirmPasswordVisible));
  }

  void changedThePassword(String oldPassword, String newPassword) async {
    emit(ChangingPassword());
    final response = await changePassword(
      ChangePasswordParams(oldPassword, newPassword),
    );
    response.fold((failure) => emit(ChangePasswordFailed(failure.message)), (
      _,
    ) {
      emit(ChangePasswordSuccess());
    });
  }
}
