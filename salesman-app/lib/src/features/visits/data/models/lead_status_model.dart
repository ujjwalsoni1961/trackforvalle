import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';

class LeadStatusModel extends LeadStatusEntity {
  const LeadStatusModel({required super.status, required super.hexColor});

  factory LeadStatusModel.fromMap(DataMap map) {
    return LeadStatusModel(
      status: map['status'] ?? "",
      hexColor: map['color']['hex'],
    );
  }
}

class LeadStatusListModel extends LeadStatusListEntity {
  const LeadStatusListModel({required super.statusList});

  factory LeadStatusListModel.fromMap(List<dynamic> list) {
    return LeadStatusListModel(
      statusList: list.map((e) => LeadStatusModel.fromMap(e)).toList(),
    );
  }
}
