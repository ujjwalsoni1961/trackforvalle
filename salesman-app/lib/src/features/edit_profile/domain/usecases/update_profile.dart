import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/edit_profile/domain/entities/user_address_entity.dart';
import 'package:track/src/features/edit_profile/domain/repositories/edit_profile_repository.dart';

class UpdateProfile extends UseCaseWithParams<UserEntity, UpdateProfileParams> {
  final EditProfileRepository _repository;

  UpdateProfile(EditProfileRepository repository) : _repository = repository;

  @override
  ResultFuture<UserEntity> call(UpdateProfileParams params) async => _repository
      .updateProfile(params.firstName, params.lastName, params.address);
}

class UpdateProfileParams extends Equatable {
  final String firstName;
  final String lastName;
  final UserAddressEntity address;

  const UpdateProfileParams({
    required this.firstName,
    required this.lastName,
    required this.address,
  });

  @override
  List<Object?> get props => [firstName, lastName, address];
}
