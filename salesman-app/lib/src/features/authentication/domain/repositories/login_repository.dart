import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

abstract class LoginRepository {
  ResultFuture<UserEntity> loginWithGoogle({required String googleAccessToken});

  ResultFuture<UserEntity> loginWithCredentials({
    required String email,
    required String password,
  });
}
