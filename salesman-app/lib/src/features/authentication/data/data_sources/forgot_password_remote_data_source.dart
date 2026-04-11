import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';

abstract class ForgotPasswordRemoteDataSource {
  Future<void> forgotPassword({required String email});
}

class ForgotPasswordRemoteDataSourceImpl
    implements ForgotPasswordRemoteDataSource {
  final API api;

  ForgotPasswordRemoteDataSourceImpl(this.api);

  @override
  Future<void> forgotPassword({required String email}) async {
    try {
      final response = await api.dio.post(
        '/auth/forget-password',
        data: {'email': email},
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        return;
      } else {
        throw APIException(
          message: response.data['error']['message'],
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
