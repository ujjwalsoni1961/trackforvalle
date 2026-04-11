import 'package:equatable/equatable.dart';

class DailyRoutesEntity extends Equatable {
  final int leadID;
  final String name;
  final double latitude;
  final double longitude;
  final int visitID;
  final String eta;
  final double distance;
  final String address;
  final String leadStatus;

  const DailyRoutesEntity({
    required this.leadID,
    required this.distance,
    required this.leadStatus,
    required this.eta,
    required this.latitude,
    required this.longitude,
    required this.name,
    required this.visitID,
    required this.address,
  });

  @override
  List<Object?> get props => [
    leadID,
    visitID,
    name,
    latitude,
    longitude,
    eta,
    distance,
    address,
  ];
}
