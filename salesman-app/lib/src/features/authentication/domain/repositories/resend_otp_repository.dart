import 'package:track/src/core/utils/typedef.dart';

abstract class ResendOtpRepository {
  ResultFutureVoid resendOtp({required String email, required String otpType});
}
