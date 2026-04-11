import 'dart:convert';

import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.email,
    required super.isEmailVerified,
    required super.accessToken,
    required super.firstName,
    required super.lastName,
    required super.userID,
    required super.fullName,
    required super.organizationName,
    required super.phoneNum,
    required super.orgId,
    required super.addressID,
    required super.roleID,
    required super.logoUrl,
    required super.refreshToken,
    required super.address,
  });

  static String getFriendlyAddress(Map<String, dynamic> address) {
    final parts = <String>[];
    parts.add(address['street_address'] ?? "");
    parts.add(address['postal_code'] ?? "");
    parts.add(address['city'] ?? "");
    parts.add(address['state'] ?? "");
    return parts.join(', ');
  }

  UserModel.fromMap(DataMap map)
    : this(
        email: map['user']['email'] as String,
        isEmailVerified: map['user']['is_email_verified'] as bool,
        accessToken: map['token'] as String,
        firstName: map['user']['first_name'] as String,
        lastName: map['user']['last_name'] as String,
        userID: map['user']['user_id'] as int,
        fullName: map['user']['full_name'] as String? ?? '',
        organizationName: map['user']['org_name'] as String? ?? '',
        logoUrl: map['user']['logo_url'] as String? ?? '',
        phoneNum: map['user']['phone'] as String? ?? '',
        orgId: map['user']['org_id'] as int? ?? -1,
        addressID: map['user']['address_id'] as int? ?? -1,
        roleID: map['user']['role_id'] as int? ?? -1,
        refreshToken: map['refreshToken'] as String,
        address: map['user']['address'] == null
            ? ""
            : UserModel.getFriendlyAddress(map['user']['address']),
      );

  UserModel.fromEditUserMap(DataMap map)
    : this(
        email: map['email'] as String,
        isEmailVerified: map['is_email_verified'] as bool,
        accessToken: map['token'] as String? ?? "",
        firstName: map['first_name'] as String,
        lastName: map['last_name'] as String,
        userID: map['user_id'] as int,
        fullName: map['full_name'] as String? ?? '',
        organizationName: map['org_name'] as String? ?? '',
        logoUrl: map['logo_url'] as String? ?? '',
        phoneNum: map['phone'] as String? ?? '',
        orgId: map['org_id'] as int? ?? -1,
        addressID: map['address_id'] as int? ?? -1,
        roleID: map['role_id'] as int? ?? -1,
        refreshToken: map['refreshToken'] as String? ?? "",
        address: map['address'] == null
            ? ""
            : UserModel.getFriendlyAddress(map['address']),
      );

  factory UserModel.fromJson(String source) =>
      UserModel.fromMap(json.decode(source));

  DataMap toMap() => {
    'user': {
      'email': email,
      'is_email_verified': isEmailVerified,
      'first_name': firstName,
      'last_name': lastName,
      'user_id': userID,
      'full_name': fullName,
      'org_name': organizationName,
      'logo_url': logoUrl,
      'phone': phoneNum,
      'org_id': orgId,
      'address_id': addressID,
      'role_id': roleID,
    },
    'token': accessToken,
    'refreshToken': refreshToken,
  };

  String toJson() => json.encode(toMap());

  const UserModel.empty()
    : super(
        email: '',
        isEmailVerified: false,
        accessToken: '',
        refreshToken: '',
        userID: 0,
        fullName: '',
        firstName: '',
        lastName: '',
        organizationName: '',
        logoUrl: '',
        phoneNum: '',
        orgId: -1,
        addressID: -1,
        roleID: -1,
        address: "",
      );
}
