import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/features/edit_profile/domain/entities/user_address_entity.dart';
import 'package:track/src/features/edit_profile/domain/usecases/update_profile.dart';

part 'edit_profile_state.dart';

class EditProfileCubit extends Cubit<EditProfileState> {
  final UpdateProfile updateProfile;
  EditProfileCubit(this.updateProfile) : super(EditProfileInitial());

  void updateTheProfile({
    required String firstName,
    required String lastName,
    required UserAddressEntity address,
  }) async {
    emit(EditProfileLoading());
    final result = await updateProfile(
      UpdateProfileParams(
        firstName: firstName,
        lastName: lastName,
        address: address,
      ),
    );
    result.fold((failure) => emit(EditProfileFailed(failure.message)), (
      remoteUser,
    ) async {
      final resLocalUser = await sl<UserLocalDataSource>().getUserData();
      resLocalUser.fold((failure) => emit(EditProfileFailed(failure.message)), (
        userLocal,
      ) async {
        final resLocal = await sl<UserLocalDataSource>().setUserData(
          userLocal.copyWith(
            firstName: remoteUser.firstName,
            lastName: remoteUser.lastName,
            address: remoteUser.address,
          ),
        );
        resLocal.fold(
          (failure) => emit(EditProfileFailed(failure.message)),
          (success) => emit(EditProfileSuccess()),
        );
      });
    });
  }
}
