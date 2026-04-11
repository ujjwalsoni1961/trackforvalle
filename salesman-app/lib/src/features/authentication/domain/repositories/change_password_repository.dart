import 'package:track/src/core/utils/typedef.dart';

abstract class ChangePasswordRepository {
  ResultFutureVoid changePassword(String oldPassword, String newPassword);
}
