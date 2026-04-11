// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserEntityAdapter extends TypeAdapter<UserEntity> {
  @override
  final int typeId = 1;

  @override
  UserEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserEntity(
      email: fields[0] as String,
      isEmailVerified: fields[3] as bool,
      accessToken: fields[1] as String,
      refreshToken: fields[2] as String,
      userID: fields[4] as int,
      fullName: fields[5] as String,
      firstName: fields[6] as String,
      lastName: fields[7] as String,
      organizationName: fields[8] as String,
      logoUrl: fields[9] as String,
      phoneNum: fields[10] as String,
      orgId: fields[11] as int,
      addressID: fields[12] as int,
      roleID: fields[13] as int,
      address: fields[14] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserEntity obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.email)
      ..writeByte(1)
      ..write(obj.accessToken)
      ..writeByte(2)
      ..write(obj.refreshToken)
      ..writeByte(3)
      ..write(obj.isEmailVerified)
      ..writeByte(4)
      ..write(obj.userID)
      ..writeByte(5)
      ..write(obj.fullName)
      ..writeByte(6)
      ..write(obj.firstName)
      ..writeByte(7)
      ..write(obj.lastName)
      ..writeByte(8)
      ..write(obj.organizationName)
      ..writeByte(9)
      ..write(obj.logoUrl)
      ..writeByte(10)
      ..write(obj.phoneNum)
      ..writeByte(11)
      ..write(obj.orgId)
      ..writeByte(12)
      ..write(obj.addressID)
      ..writeByte(13)
      ..write(obj.roleID)
      ..writeByte(14)
      ..write(obj.address);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
