import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';
part 'verify_otp_entity.g.dart';

@HiveType(typeId: 0)
class VerifyOtpEntity extends Equatable {
  @HiveField(0)
  final String token;

  const VerifyOtpEntity({
    required this.token,
  });

  @override
  List<Object?> get props => [token];
}
