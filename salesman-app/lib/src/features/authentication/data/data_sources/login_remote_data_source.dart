import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/data/models/user_model.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

abstract class LoginRemoteDataSource {
  Future<UserEntity> loginWithGoogle({required String googleAccessToken});

  Future<UserEntity> loginWithCredentials({
    required String email,
    required String password,
  });
}

class LoginRemoteDataSourceImpl implements LoginRemoteDataSource {
  final API api;

  LoginRemoteDataSourceImpl(this.api);
  @override
  Future<UserEntity> loginWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      final response = await api.dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
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

  @override
  Future<UserEntity> loginWithGoogle({
    required String googleAccessToken,
  }) async {
    try {
      final response = await api.dio.post(
        '/auth/google',
        data: {'google_auth_token': googleAccessToken},
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
