import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_entity.dart';

class RefreshRoutesModel extends RefreshRoutesEntity {
  const RefreshRoutesModel({
    required super.leadID,
    required super.visitID,
    required super.distance,
    required super.eta,
  });

  factory RefreshRoutesModel.fromMap(DataMap map) {
    return RefreshRoutesModel(
      leadID: map['lead_id'] as int? ?? 0,
      visitID: map['visit_id'] as int,
      distance: (map['distance'] is num)
          ? (map['distance'] as num).toDouble()
          : 0.0,
      eta: map['eta'] as String? ?? "",
    );
  }
}
