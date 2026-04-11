import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

part 'profile_details_state.dart';

class ProfileDetailsCubit extends Cubit<ProfileDetailsState> {
  ProfileDetailsCubit() : super(ProfileDetailsInitial());

  void fetchProfileDetailsLocal() async {
    emit(ProfileDetailsLoading());

    final resLocal = await sl<UserLocalDataSource>().getUserData();

    resLocal.fold((failure) => emit(ProfileDetailsFailed(failure.message)), (
      userData,
    ) {
      emit(ProfileDetailsLoaded(userData));
    });
  }
}
