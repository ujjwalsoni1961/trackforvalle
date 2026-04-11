import 'dart:convert';
import 'dart:developer';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/authentication/domain/entities/verify_otp_entity.dart';

class VerifyOtpModel extends VerifyOtpEntity {
  const VerifyOtpModel({required super.token});

  VerifyOtpModel.fromMap(DataMap map) : this(token: map['token'] as String);

  factory VerifyOtpModel.fromJson(String source) =>
      VerifyOtpModel.fromMap(json.decode(source));

  DataMap toMap() => {'token': super.token};

  String toJson() => json.encode(toMap());

  VerifyOtpModel copyWith({String? token}) {
    return VerifyOtpModel(token: token ?? this.token);
  }

  const VerifyOtpModel.empty() : super(token: '');
  VerifyOtpModel.fromEntity(VerifyOtpEntity entity) : this(token: entity.token);

  void logData() {
    log('************ RegisterModel ************');
    log('token: ${super.token}');
  }
}
