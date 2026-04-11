import 'package:equatable/equatable.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';

class LeadsListEntity extends Equatable {
  final List<LeadsDetailsEntity> allLeads;
  final PaginationEntity paginationData;
  final int totalLeads;
  final int visitedLeads;
  final int remainingLeads;
  const LeadsListEntity({
    required this.allLeads,
    required this.paginationData,
    required this.totalLeads,
    required this.visitedLeads,
    required this.remainingLeads,
  });

  static LeadsListEntity empty() => LeadsListEntity(
    allLeads: const [],
    paginationData: PaginationEntity.empty(),
    totalLeads: 0,
    visitedLeads: 0,
    remainingLeads: 0,
  );
  @override
  List<Object?> get props => [
    allLeads,
    paginationData,
    totalLeads,
    visitedLeads,
    remainingLeads,
  ];
}

class PaginationEntity extends Equatable {
  final int pageNumber;
  final int totalPages;
  final int total;
  final int limit;

  static PaginationEntity empty() =>
      const PaginationEntity(pageNumber: 1, totalPages: 1, limit: 10, total: 0);

  const PaginationEntity({
    required this.pageNumber,
    required this.totalPages,
    required this.total,
    required this.limit,
  });

  @override
  List<Object?> get props => [pageNumber, totalPages, limit, total];
}
