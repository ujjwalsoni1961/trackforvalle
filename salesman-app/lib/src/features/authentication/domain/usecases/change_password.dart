import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/repositories/change_password_repository.dart';

class ChangePassword extends UseCaseWithParams<void, ChangePasswordParams> {
  final ChangePasswordRepository _repository;

  ChangePassword(ChangePasswordRepository repository)
    : _repository = repository;

  @override
  ResultFutureVoid call(ChangePasswordParams params) async =>
      await _repository.changePassword(params.oldPassword, params.newPassword);
}

class ChangePasswordParams {
  final String oldPassword;
  final String newPassword;

  ChangePasswordParams(this.oldPassword, this.newPassword);
}
