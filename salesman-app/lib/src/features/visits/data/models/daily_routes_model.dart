import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_entity.dart';

class DailyRoutesModel extends DailyRoutesEntity {
  const DailyRoutesModel({
    required super.leadID,
    required super.visitID,
    required super.name,
    required super.latitude,
    required super.longitude,
    required super.distance,
    required super.eta,
    required super.address,
    required super.leadStatus,
  });

  factory DailyRoutesModel.fromMap(DataMap map) {
    return DailyRoutesModel(
      leadID: map['lead_id'] as int? ?? 0,
      leadStatus: map['lead_status'] ?? "",
      visitID: map['visit_id'] as int,
      name: map['name'] as String? ?? "",
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      distance: double.tryParse(map['distance'].toString()) ?? 0,
      eta: map['eta'] as String? ?? "",
      address: map['address'] as String? ?? "",
    );
  }
}
