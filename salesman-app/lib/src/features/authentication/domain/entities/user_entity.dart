import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'user_entity.g.dart';

@HiveType(typeId: 1)
class UserEntity extends Equatable {
  @HiveField(0)
  final String email;
  @HiveField(1)
  final String accessToken;
  @HiveField(2)
  final String refreshToken;
  @HiveField(3)
  final bool isEmailVerified;
  @HiveField(4)
  final int userID;
  @HiveField(5)
  final String fullName;
  @HiveField(6)
  final String firstName;
  @HiveField(7)
  final String lastName;
  @HiveField(8)
  final String organizationName;
  @HiveField(9)
  final String logoUrl;
  @HiveField(10)
  final String phoneNum;
  @HiveField(11)
  final int orgId;
  @HiveField(12)
  final int addressID;
  @HiveField(13)
  final int roleID;
  @HiveField(14)
  final String address;

  const UserEntity({
    required this.email,
    required this.isEmailVerified,
    required this.accessToken,
    required this.refreshToken,
    required this.userID,
    required this.fullName,
    required this.firstName,
    required this.lastName,
    required this.organizationName,
    required this.logoUrl,
    required this.phoneNum,
    required this.orgId,
    required this.addressID,
    required this.roleID,
    required this.address,
  });

  @override
  List<Object> get props => [email, isEmailVerified, accessToken];

  UserEntity copyWith({
    String? email,
    String? accessToken,
    String? refreshToken,
    bool? isEmailVerified,
    int? userID,
    String? fullName,
    String? firstName,
    String? lastName,
    String? organizationName,
    String? logoUrl,
    String? phoneNum,
    int? orgId,
    int? addressID,
    int? roleID,
    String? address,
  }) {
    return UserEntity(
      email: email ?? this.email,
      accessToken: accessToken ?? this.accessToken,
      refreshToken: refreshToken ?? this.refreshToken,
      isEmailVerified: isEmailVerified ?? this.isEmailVerified,
      userID: userID ?? this.userID,
      fullName: fullName ?? this.fullName,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      organizationName: organizationName ?? this.organizationName,
      logoUrl: logoUrl ?? this.logoUrl,
      phoneNum: phoneNum ?? this.phoneNum,
      orgId: orgId ?? this.orgId,
      addressID: addressID ?? this.addressID,
      roleID: roleID ?? this.roleID,
      address: address ?? this.address,
    );
  }
}
