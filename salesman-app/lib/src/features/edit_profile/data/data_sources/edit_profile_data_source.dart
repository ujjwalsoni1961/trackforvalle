import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/features/authentication/data/models/user_model.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/edit_profile/domain/entities/user_address_entity.dart';

abstract class EditProfileDataSource {
  Future<UserEntity> updateProfile(
    String firstName,
    String lastName,
    UserAddressEntity address,
  );
}

class EditProfileDataSourceImpl extends EditProfileDataSource {
  final API _api;

  EditProfileDataSourceImpl(this._api);
  @override
  Future<UserEntity> updateProfile(
    String firstName,
    String lastName,
    UserAddressEntity address,
  ) async {
    try {
      final response = await _api.dio.post(
        '/user/update-profile',
        data: {
          "first_name": firstName,
          "last_name": lastName,
          "address": {
            "street_address": address.streetAddress,
            "city": address.city,
            "state": address.state,
          },
        },
      );
      if (response.statusCode == 200) {
        return UserModel.fromEditUserMap(response.data['data']);
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
