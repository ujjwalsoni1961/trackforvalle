import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_list_entity.dart';

abstract class LeadsRepository {
  ResultFuture<LeadsListEntity> getLeads({
    required int pageNumber,
    required int limit,
    String? query,
  });
  ResultFutureVoid addLead({
    required String name,
    required String contactName,
    required String contactEmail,
    required String contactPhone,
    required String streetAddress,
    required String city,
    required String state,
    required String postalCode,
    required String areaName,
    required String subregion,
    required String region,
    required String country,
  });
  ResultFuture<LeadsDetailsEntity> updateLeadDetails({
    required int leadID,
    String? contactName,
    String? contactEmail,
    String? contactPhone,
    String? streetAddress,
    String? postalCode,
    String? areaName,
    String? subregion,
    String? region,
    String? country,
    String? status,
  });

  ResultFuture<LeadStatusListEntity> getLeadStatusList();
}
