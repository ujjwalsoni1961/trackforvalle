import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/edit_profile/domain/entities/user_address_entity.dart';

abstract class EditProfileRepository {
  ResultFuture<UserEntity> updateProfile(
    String firstName,
    String lastName,
    UserAddressEntity address,
  );
}
