import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';

abstract class ChangePasswordRemoteDataSource {
  Future<void> changePassword(String oldPassword, String newPassword);
}

class ChangePasswordRemoteDataSourceImpl
    extends ChangePasswordRemoteDataSource {
  final API _api;

  ChangePasswordRemoteDataSourceImpl(this._api);
  @override
  Future<void> changePassword(String oldPassword, String newPassword) async {
    try {
      final response = await _api.dio.post(
        '/auth/change-password',
        data: {'oldPassword': oldPassword, 'newPassword': newPassword},
      );
      if (response.statusCode == 200) {
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
