import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

abstract class RegisterRepository {
  ResultFuture<UserEntity> registerWithCredentials({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNum,
    required String orgName,
    required String password,
  });
}
