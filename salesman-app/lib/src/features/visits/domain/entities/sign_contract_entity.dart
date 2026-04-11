import 'package:equatable/equatable.dart';

class SignContractEntity extends Equatable {
  final int contractID;
  final int visitID;

  const SignContractEntity({required this.contractID, required this.visitID});

  @override
  List<Object?> get props => [contractID, visitID];
}
