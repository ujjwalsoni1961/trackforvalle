import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/usecases/login_with_credentials.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final LoginWithCredentials loginWithCredentials;
  final UserLocalDataSource userLocalDataSource;
  LoginCubit(this.loginWithCredentials, this.userLocalDataSource)
    : super(LoginInitial());

  bool isPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityChanged(isPasswordVisible));
  }

  void login(String email, String password) async {
    emit(LoggingIn());
    final response = await loginWithCredentials(
      LoginWithCredentialsParams(email: email, password: password),
    );
    response.fold(
      (failure) {
        emit(LoginFailed(failure.message));
      },
      (userData) async {
        final resLocal = await userLocalDataSource.setUserData(userData);
        resLocal.fold(
          (failure) => emit(LoginFailed(failure.message)),
          (_) => emit(LoginSuccess(userData)),
        );
      },
    );
  }
}
