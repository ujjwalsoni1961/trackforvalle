import 'package:equatable/equatable.dart';
import 'package:track/src/core/errors/exceptions.dart';

abstract class Failure extends Equatable {
  final String message;
  final int statusCode;

  const Failure({required this.message, required this.statusCode});
  @override
  List<Object> get props => [statusCode];
}

class APIFailure extends Failure {
  const APIFailure({required super.message, required super.statusCode});

  APIFailure.fromAPIException(APIException exception)
    : super(message: exception.message, statusCode: exception.statusCode);
}

class HiveFailure extends Failure {
  const HiveFailure({required super.message, required super.statusCode});
}
