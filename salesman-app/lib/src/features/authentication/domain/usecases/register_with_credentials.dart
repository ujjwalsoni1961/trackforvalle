import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/authentication/domain/entities/user_entity.dart';
import 'package:track/src/features/authentication/domain/repositories/register_repository.dart';

class RegisterWithCredentials
    extends UseCaseWithParams<void, RegisterWithCredentialsParams> {
  final RegisterRepository _repository;

  RegisterWithCredentials(RegisterRepository repository)
    : _repository = repository;

  @override
  ResultFuture<UserEntity> call(RegisterWithCredentialsParams params) async =>
      _repository.registerWithCredentials(
        email: params.email,
        password: params.password,
        firstName: params.firstName,
        lastName: params.lastName,
        phoneNum: params.phoneNum,
        orgName: params.orgName,
      );
}

class RegisterWithCredentialsParams extends Equatable {
  final String email;
  final String firstName;
  final String lastName;
  final String phoneNum;
  final String orgName;
  final String password;

  const RegisterWithCredentialsParams({
    required this.firstName,
    required this.lastName,
    required this.phoneNum,
    required this.orgName,
    required this.email,
    required this.password,
  });

  @override
  List<Object?> get props => [
    email,
    password,
    firstName,
    lastName,
    phoneNum,
    orgName,
  ];
}
