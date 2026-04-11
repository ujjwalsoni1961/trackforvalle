import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/data_sources/login_remote_data_source.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/repositories/login_repository.dart';

class LoginRepositoryImpl extends LoginRepository {
  final LoginRemoteDataSource _remoteDataSource;

  LoginRepositoryImpl(LoginRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFuture<UserEntity> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final loginData = await _remoteDataSource.loginWithCredentials(
        email: email,
        password: password,
      );
      return Right(loginData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<UserEntity> loginWithGoogle({
    required String googleAccessToken,
  }) async {
    try {
      final loginData = await _remoteDataSource.loginWithGoogle(
        googleAccessToken: googleAccessToken,
      );
      return Right(loginData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
