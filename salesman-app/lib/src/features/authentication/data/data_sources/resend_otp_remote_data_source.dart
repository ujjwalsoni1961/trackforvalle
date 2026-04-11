import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/core/utils/typedef.dart';

abstract class ResendOtpRemoteDataSource {
  Future<void> resendOtp({required String email, required String otpType});
}

class ResendOtpRemoteDataSourceImpl implements ResendOtpRemoteDataSource {
  final API api;

  ResendOtpRemoteDataSourceImpl(this.api);
  @override
  Future<void> resendOtp({
    required String email,
    required String otpType,
  }) async {
    try {
      final response = await api.dio.post(
        '/auth/resend-otp',
        data: {'email': email, 'otp_type': otpType},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw APIException(
          message: (response.data as DataMap)['error']['message'],
          statusCode: response.statusCode ?? 500,
        );
      }
    } on APIException {
      rethrow;
    } catch (e) {
      throw APIException(
        message: e is APIException ? e.message : e.runtimeType.toString(),
        statusCode: 505,
      );
    }
  }
}
