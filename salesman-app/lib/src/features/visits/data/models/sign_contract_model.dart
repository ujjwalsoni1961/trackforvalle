import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/sign_contract_entity.dart';

class SignContractModel extends SignContractEntity {
  const SignContractModel({required super.contractID, required super.visitID});

  factory SignContractModel.fromMap(DataMap map) {
    return SignContractModel(
      visitID: map['visit_id'] as int,
      contractID: map['id'],
    );
  }
}
