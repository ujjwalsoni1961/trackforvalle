import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/core/utils/typedef.dart';

abstract class VerifyOTPRemoteDataSource {
  Future<void> verifyEmail({
    required String email,
    required String otp,
    required String type,
  });
}

class VerifyOTPRemoteDataSourceImpl implements VerifyOTPRemoteDataSource {
  final API api;

  VerifyOTPRemoteDataSourceImpl(this.api);
  @override
  Future<void> verifyEmail({
    required String email,
    required String otp,
    required String type,
  }) async {
    try {
      final response = await api.dio.post(
        '/auth/verify-otp',
        data: {'email': email, 'otp': otp, 'otp_type': type},
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
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
