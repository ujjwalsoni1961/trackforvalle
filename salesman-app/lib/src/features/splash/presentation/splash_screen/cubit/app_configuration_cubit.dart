import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
part 'app_configuration_state.dart';

class AppConfigurationCubit extends Cubit<AppConfigurationState> {
  AppConfigurationCubit() : super(AppConfigurationInitial());

  void checkUserLoggedIn() async {
    emit(UserLoading());
    print('🔍 Checking if user is logged in...');

    final res = await sl<UserLocalDataSource>().getUserData();

    print('📦 Result received from getUserData');

    await Future.delayed(const Duration(milliseconds: 800));

    res.fold(
      (failure) {
        print('❌ User not logged in - Failure: ${failure.message}');
        emit(UserNotLoggedIn());
      },
      (userData) {
        print('✅ User logged in - Email: ${userData.email}');
        emit(UserLoggedIn());
      },
    );
  }
}
