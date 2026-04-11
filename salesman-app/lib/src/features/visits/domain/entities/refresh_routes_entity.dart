import 'package:equatable/equatable.dart';

class RefreshRoutesEntity extends Equatable {
  final int leadID;
  final int visitID;
  final String eta;
  final double distance;

  const RefreshRoutesEntity({
    required this.leadID,
    required this.distance,
    required this.eta,
    required this.visitID,
  });

  @override
  List<Object?> get props => [leadID, visitID, eta, distance];
}
