// Item Model
import 'package:track/src/features/visits/data/models/leads_model.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';

class PastVisitItemModel extends PastVisitItemEntity {
  const PastVisitItemModel({
    required super.visitId,
    required super.leadId,
    required super.repId,
    required super.checkInTime,
    required super.checkOutTime,
    required super.latitude,
    required super.longitude,
    required super.notes,
    required super.nextVisitDate,
    required super.actionRequired,
    required super.isActive,
    required super.createdBy,
    required super.updatedBy,
    required super.createdAt,
    required super.updatedAt,
    required super.lead,
    super.contract,
    super.status,
    super.followUpVisits,
  });

  factory PastVisitItemModel.fromMap(Map<String, dynamic> map) {
    return PastVisitItemModel(
      visitId: map['visit_id'] ?? 0,
      leadId: map['lead_id'] ?? 0,
      repId: map['rep_id'] ?? 0,
      checkInTime: DateTime.parse(
        map['check_in_time'] ?? DateTime.now().toIso8601String(),
      ),

      checkOutTime: map['check_out_time'] != null
          ? DateTime.parse(map['check_out_time'])
          : DateTime.now(),
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
      notes: map['notes'] ?? '',
      nextVisitDate: map['next_visit_date'] != null
          ? DateTime.parse(map['next_visit_date'])
          : DateTime.now(),
      actionRequired: map['action_required'] ?? '',
      isActive: map['is_active'] ?? false,
      createdBy: map['created_by'] ?? '',
      updatedBy: map['updated_by'] ?? '',
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      status: map['status'],
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
      lead: LeadsDetailsModel.fromMap(map['lead'] ?? {}),

      contract: map['contract'] != null
          ? ContractModel.fromMap(map['contract'])
          : null,
      followUpVisits: map['followUpVisits'] != null
          ? (map['followUpVisits'] as List)
                .map((e) => FollowUpVisitModel.fromMap(e))
                .toList()
          : null,
    );
  }
}

// Contract Model
class ContractModel extends ContractEntity {
  const ContractModel({
    required super.id,
    required super.contractTemplateId,
    required super.visitId,
    required super.renderedHtml,
    required super.signedAt,
  });

  factory ContractModel.fromMap(Map<String, dynamic> map) {
    return ContractModel(
      id: map['id'] ?? 0,
      contractTemplateId: map['contract_template_id'] ?? 0,
      visitId: map['visit_id'] ?? 0,
      renderedHtml: map['rendered_html'] ?? '',
      signedAt: DateTime.parse(
        map['signed_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

// FollowUpVisit Model
class FollowUpVisitModel extends FollowUpVisitEntity {
  const FollowUpVisitModel({
    required super.followUpVisitId,
    required super.followUpId,
    required super.visitId,
    required super.createdAt,
    required super.followUp,
  });

  factory FollowUpVisitModel.fromMap(Map<String, dynamic> map) {
    return FollowUpVisitModel(
      followUpVisitId: map['follow_up_visit_id'] ?? 0,
      followUpId: map['follow_up_id'] ?? 0,
      visitId: map['visit_id'] ?? 0,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      followUp: FollowUpModel.fromMap(map['followUp'] ?? {}),
    );
  }
}

// FollowUp Model
class FollowUpModel extends FollowUpEntity {
  const FollowUpModel({
    required super.followUpId,
    required super.subject,
    required super.notes,
    required super.scheduledDate,
    required super.isCompleted,
    required super.createdBy,
    required super.createdAt,
    required super.updatedAt,
  });

  factory FollowUpModel.fromMap(Map<String, dynamic> map) {
    return FollowUpModel(
      followUpId: map['follow_up_id'] ?? 0,
      subject: map['subject'] ?? '',
      notes: map['notes'] ?? '',
      scheduledDate: DateTime.parse(
        map['scheduled_date'] ?? DateTime.now().toIso8601String(),
      ),
      isCompleted: map['is_completed'] ?? false,
      createdBy: map['created_by'] ?? 0,
      createdAt: DateTime.parse(
        map['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        map['updated_at'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}

// Visit List Model
class PastVisitsListModel extends PastVisitsListEntity {
  const PastVisitsListModel({required super.visits, required super.pagination});

  factory PastVisitsListModel.fromMap(Map<String, dynamic> map) {
    return PastVisitsListModel(
      visits: (map['data'] as List)
          .map((e) => PastVisitItemModel.fromMap(e))
          .toList(),
      pagination: PaginationModel.fromMap(map['pagination']),
    );
  }
}

// Pagination Model
class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.totalItems,
    required super.currentPage,
    required super.totalPages,
  });

  factory PaginationModel.fromMap(Map<String, dynamic> map) {
    return PaginationModel(
      totalItems: map['totalItems'] ?? 0,
      currentPage: map['currentPage'] ?? 1,
      totalPages: map['totalPages'] ?? 1,
    );
  }
}
