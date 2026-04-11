import 'package:equatable/equatable.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';

// Item Entity
class PastVisitItemEntity extends Equatable {
  final int visitId;
  final int leadId;
  final int repId;
  final DateTime checkInTime;
  final DateTime checkOutTime;
  final double latitude;
  final String? status;
  final double longitude;
  final String notes;
  final DateTime nextVisitDate;
  final String actionRequired;
  final bool isActive;
  final String createdBy;
  final String updatedBy;
  final DateTime createdAt;
  final DateTime updatedAt;
  final LeadsDetailsEntity lead;
  final ContractEntity? contract;
  final List<FollowUpVisitEntity>? followUpVisits;

  const PastVisitItemEntity({
    required this.visitId,
    required this.leadId,
    required this.repId,
    required this.checkInTime,
    required this.checkOutTime,
    required this.latitude,
    required this.longitude,
    required this.notes,
    required this.nextVisitDate,
    required this.actionRequired,
    required this.isActive,
    required this.createdBy,
    required this.updatedBy,
    required this.createdAt,
    required this.updatedAt,
    required this.lead,
    this.contract,
    this.status,
    this.followUpVisits,
  });

  factory PastVisitItemEntity.empty() => PastVisitItemEntity(
    visitId: 0,
    leadId: 0,
    repId: 0,
    checkInTime: DateTime.fromMillisecondsSinceEpoch(0),
    checkOutTime: DateTime.fromMillisecondsSinceEpoch(0),
    latitude: 0.0,
    longitude: 0.0,
    notes: '',
    status: "",
    nextVisitDate: DateTime.fromMillisecondsSinceEpoch(0),
    actionRequired: '',
    isActive: false,
    createdBy: '',
    updatedBy: '',
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
    lead: LeadsDetailsEntity.empty(),
    contract: null,
    followUpVisits: const [],
  );

  @override
  List<Object?> get props => [
    visitId,
    leadId,
    repId,
    checkInTime,
    checkOutTime,
    latitude,
    status,
    longitude,
    notes,
    nextVisitDate,
    actionRequired,
    isActive,
    createdBy,
    updatedBy,
    createdAt,
    updatedAt,
    lead,
    contract,
    followUpVisits,
  ];
}

// Contract Entity
class ContractEntity extends Equatable {
  final int id;
  final int contractTemplateId;
  final int visitId;
  final String renderedHtml;
  final DateTime signedAt;

  const ContractEntity({
    required this.id,
    required this.contractTemplateId,
    required this.visitId,
    required this.renderedHtml,
    required this.signedAt,
  });

  factory ContractEntity.empty() => ContractEntity(
    id: 0,
    contractTemplateId: 0,
    visitId: 0,
    renderedHtml: '',
    signedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  List<Object> get props => [
    id,
    contractTemplateId,
    visitId,
    renderedHtml,
    signedAt,
  ];
}

// FollowUpVisit Entity
class FollowUpVisitEntity extends Equatable {
  final int followUpVisitId;
  final int followUpId;
  final int visitId;
  final DateTime createdAt;
  final FollowUpEntity followUp;

  const FollowUpVisitEntity({
    required this.followUpVisitId,
    required this.followUpId,
    required this.visitId,
    required this.createdAt,
    required this.followUp,
  });

  factory FollowUpVisitEntity.empty() => FollowUpVisitEntity(
    followUpVisitId: 0,
    followUpId: 0,
    visitId: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    followUp: FollowUpEntity.empty(),
  );

  @override
  List<Object> get props => [
    followUpVisitId,
    followUpId,
    visitId,
    createdAt,
    followUp,
  ];
}

// FollowUp Entity
class FollowUpEntity extends Equatable {
  final int followUpId;
  final String subject;
  final String notes;
  final DateTime scheduledDate;
  final bool isCompleted;
  final int createdBy;
  final DateTime createdAt;
  final DateTime updatedAt;

  const FollowUpEntity({
    required this.followUpId,
    required this.subject,
    required this.notes,
    required this.scheduledDate,
    required this.isCompleted,
    required this.createdBy,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FollowUpEntity.empty() => FollowUpEntity(
    followUpId: 0,
    subject: '',
    notes: '',
    scheduledDate: DateTime.fromMillisecondsSinceEpoch(0),
    isCompleted: false,
    createdBy: 0,
    createdAt: DateTime.fromMillisecondsSinceEpoch(0),
    updatedAt: DateTime.fromMillisecondsSinceEpoch(0),
  );

  @override
  List<Object> get props => [
    followUpId,
    subject,
    notes,
    scheduledDate,
    isCompleted,
    createdBy,
    createdAt,
    updatedAt,
  ];
}

// Visit List Entity
class PastVisitsListEntity extends Equatable {
  final List<PastVisitItemEntity> visits;
  final PaginationEntity pagination;

  const PastVisitsListEntity({required this.visits, required this.pagination});

  factory PastVisitsListEntity.empty() => PastVisitsListEntity(
    visits: const [],
    pagination: PaginationEntity.empty(),
  );

  @override
  List<Object> get props => [visits, pagination];
}

// Pagination Entity
class PaginationEntity extends Equatable {
  final int totalItems;
  final int currentPage;
  final int totalPages;

  const PaginationEntity({
    required this.totalItems,
    required this.currentPage,
    required this.totalPages,
  });

  factory PaginationEntity.empty() =>
      const PaginationEntity(totalItems: 0, currentPage: 0, totalPages: 0);

  @override
  List<Object> get props => [totalItems, currentPage, totalPages];
}
