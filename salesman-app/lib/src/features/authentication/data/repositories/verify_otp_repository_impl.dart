import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/data_sources/verify_remote_data_source.dart';
import 'package:track/src/features/authentication/domain/repositories/verify_otp_repository.dart';

class VerifyOTPRepositoryImpl extends VerifyOTPRepository {
  final VerifyOTPRemoteDataSource _remoteDataSource;

  VerifyOTPRepositoryImpl(VerifyOTPRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFutureVoid verifyEmail({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      await _remoteDataSource.verifyEmail(email: email, otp: otp, type: type);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
