import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/data_sources/register_remote_data_source.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/repositories/register_repository.dart';

class RegistorRepositoryImpl implements RegisterRepository {
  final RegisterRemoteDataSource _remoteDataSource;

  RegistorRepositoryImpl(RegisterRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFuture<UserEntity> registerWithCredentials({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNum,
    required String orgName,
    required String password,
  }) async {
    try {
      UserEntity userData = await _remoteDataSource.registerWithCredentials(
        email: email,
        firstName: firstName,
        lastName: lastName,
        phoneNum: phoneNum,
        orgName: orgName,
        password: password,
      );

      return Right(userData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
