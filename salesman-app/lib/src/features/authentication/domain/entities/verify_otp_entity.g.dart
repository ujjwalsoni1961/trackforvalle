// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'verify_otp_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class VerifyOtpEntityAdapter extends TypeAdapter<VerifyOtpEntity> {
  @override
  final int typeId = 0;

  @override
  VerifyOtpEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return VerifyOtpEntity(
      token: fields[0] as String,
    );
  }

  @override
  void write(BinaryWriter writer, VerifyOtpEntity obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.token);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VerifyOtpEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
