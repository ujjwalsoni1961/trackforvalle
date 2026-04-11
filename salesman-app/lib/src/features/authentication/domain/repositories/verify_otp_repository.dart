import 'package:track/src/core/utils/typedef.dart';

abstract class VerifyOTPRepository {
  ResultFutureVoid verifyEmail({
    required String email,
    required String otp,
    required String type,
  });
}
