import 'package:equatable/equatable.dart';

class LeadStatusEntity extends Equatable {
  final String status;
  final String hexColor;

  const LeadStatusEntity({required this.status, required this.hexColor});

  @override
  List<Object?> get props => [status, hexColor];
}

class LeadStatusListEntity extends Equatable {
  final List<LeadStatusEntity> statusList;

  const LeadStatusListEntity({required this.statusList});

  @override
  List<Object?> get props => [statusList];
}
