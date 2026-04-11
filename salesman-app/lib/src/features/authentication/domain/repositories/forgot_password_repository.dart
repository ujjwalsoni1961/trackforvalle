import 'package:track/src/core/utils/typedef.dart';

abstract class ForgetPasswordRepository {
  ResultFutureVoid forgotPassword({required String email});
}
