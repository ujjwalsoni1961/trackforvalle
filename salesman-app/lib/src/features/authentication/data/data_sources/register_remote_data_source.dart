import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/models/user_model.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

abstract class RegisterRemoteDataSource {
  Future<UserEntity> registerWithCredentials({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNum,
    required String orgName,
    required String password,
  });
}

class RegisterRemoteDataSourceImpl implements RegisterRemoteDataSource {
  final API api;

  RegisterRemoteDataSourceImpl(this.api);
  @override
  Future<UserEntity> registerWithCredentials({
    required String email,
    required String firstName,
    required String lastName,
    required String phoneNum,
    required String orgName,
    required String password,
  }) async {
    try {
      final response = await api.dio.post(
        '/auth/register',
        data: {
          'email': email,
          'first_name': firstName,
          'last_name': lastName,
          'phone_no': phoneNum,
          'org_name': orgName,
          'password': password,
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return UserModel.fromMap(response.data['data']);
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
