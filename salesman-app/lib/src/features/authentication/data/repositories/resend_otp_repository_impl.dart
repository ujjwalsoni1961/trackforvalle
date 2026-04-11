import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/data_sources/resend_otp_remote_data_source.dart';
import 'package:track/src/features/authentication/domain/repositories/resend_otp_repository.dart';

class ResendOtpRepositoryImpl implements ResendOtpRepository {
  final ResendOtpRemoteDataSource _remoteDataSource;

  ResendOtpRepositoryImpl(ResendOtpRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;
  @override
  ResultFutureVoid resendOtp({
    required String email,
    required String otpType,
  }) async {
    try {
      await _remoteDataSource.resendOtp(email: email, otpType: otpType);
      return const Right(null);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
