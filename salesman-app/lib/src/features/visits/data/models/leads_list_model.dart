import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/data/models/leads_model.dart';
import 'package:track/src/features/visits/domain/entities/leads_list_entity.dart';

class LeadsListModel extends LeadsListEntity {
  const LeadsListModel({
    required super.allLeads,
    required super.totalLeads,
    required super.visitedLeads,
    required super.remainingLeads,
    required super.paginationData,
  });

  factory LeadsListModel.fromMap(DataMap map) {
    return LeadsListModel(
      allLeads: (map['leads'] as List<dynamic>)
          .map((lead) => LeadsDetailsModel.fromMap(lead))
          .toList(),
      paginationData: PaginationModel.fromMap(map['pagination'] as DataMap),
      totalLeads: 30,
      visitedLeads: 10,
      remainingLeads: 20,
    );
  }
}

class PaginationModel extends PaginationEntity {
  const PaginationModel({
    required super.pageNumber,
    required super.totalPages,
    required super.limit,
    required super.total,
  });

  factory PaginationModel.fromMap(DataMap map) {
    return PaginationModel(
      pageNumber: map['page'],
      totalPages: map['totalPages'],
      limit: map['limit'],
      total: map['total'] ?? 0,
    );
  }
}
