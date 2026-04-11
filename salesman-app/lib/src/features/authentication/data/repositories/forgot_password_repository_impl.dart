import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/data_sources/forgot_password_remote_data_source.dart';
import 'package:track/src/features/authentication/domain/repositories/forgot_password_repository.dart';

class ForgotPasswordRepositoryImpl extends ForgetPasswordRepository {
  final ForgotPasswordRemoteDataSource _remoteDataSource;

  ForgotPasswordRepositoryImpl(ForgotPasswordRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFutureVoid forgotPassword({required String email}) async {
    try {
      final forgotPasswordData = await _remoteDataSource.forgotPassword(
        email: email,
      );
      return Right(forgotPasswordData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
