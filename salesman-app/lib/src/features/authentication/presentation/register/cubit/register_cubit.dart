import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/core/ui/res/avatar_models.dart';
import 'package:track/src/features/authentication/domain/usecases/register_with_credentials.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final RegisterWithCredentials registerWithCredentials;

  RegisterCubit(this.registerWithCredentials) : super(RegisterInitial());

  String avatarId = AvatarModels.avatars[0].id;
  bool isPasswordVisible = false;
  bool isConfirmPasswordVisible = false;

  void togglePasswordVisibility() {
    isPasswordVisible = !isPasswordVisible;
    emit(PasswordVisibilityChanged(isPasswordVisible));
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible = !isConfirmPasswordVisible;
    emit(ConfirmPasswordVisibilityChanged(isConfirmPasswordVisible));
  }

  void register({
    required String email,
    required password,
    required firstName,
    required lastName,
    required phoneNum,
    required orgName,
  }) async {
    emit(Registering());
    final response = await registerWithCredentials(
      RegisterWithCredentialsParams(
        email: email,
        password: password,
        firstName: firstName,
        lastName: lastName,
        phoneNum: phoneNum,
        orgName: orgName,
      ),
    );
    response.fold((failure) => emit(RegisterFailed(failure.message)), (
      userData,
    ) async {
      final userLocalDataSource = sl<UserLocalDataSource>();
      final resLocal = await userLocalDataSource.setUserData(userData);
      resLocal.fold(
        (failure) => emit(RegisterFailed(failure.message)),
        (_) => emit(const RegisterSuccess()),
      );
    });
  }
}
