import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/data_sources/change_password_remote_data_source.dart';
import 'package:track/src/features/authentication/domain/repositories/change_password_repository.dart';

class ChangePasswordRepositoryImpl extends ChangePasswordRepository {
  final ChangePasswordRemoteDataSource _remoteDataSource;

  ChangePasswordRepositoryImpl(ChangePasswordRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFutureVoid changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    try {
      await _remoteDataSource.changePassword(oldPassword, newPassword);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
