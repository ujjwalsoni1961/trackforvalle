import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';

class LeadsAddressModel extends LeadsAddressEntity {
  const LeadsAddressModel({
    required super.addressId,
    required super.streetAddress,
    required super.buildingUnit,
    required super.landmark,
    required super.city,
    required super.state,
    required super.postalCode,
    required super.areaName,
    required super.subregion,
    required super.region,
    required super.country,
    required super.latitude,
    required super.longitude,
    required super.orgId,
    super.territoryId,
    super.polygonId,
    super.comments,
  });

  factory LeadsAddressModel.empty() {
    return LeadsAddressModel(
      addressId: 0,
      streetAddress: '',
      buildingUnit: '',
      landmark: '',
      city: '',
      state: '',
      postalCode: '',
      areaName: '',
      subregion: '',
      region: '',
      country: '',
      latitude: 0.0,
      longitude: 0.0,
      orgId: 0,
      territoryId: null,
      polygonId: null,
      comments: '',
    );
  }

  factory LeadsAddressModel.fromMap(DataMap map) {
    return LeadsAddressModel(
      addressId: map['address_id'],
      streetAddress: map['street_address'] as String? ?? '',
      buildingUnit: map['building_unit'] as String? ?? '',
      landmark: map['landmark'] as String? ?? '',
      city: map['city'] as String? ?? '',
      state: map['state'] as String? ?? '',
      postalCode: map['postal_code'] as String? ?? '',
      areaName: map['area_name'] as String? ?? '',
      subregion: map['subregion'] as String? ?? '',
      region: map['region'] as String? ?? '',
      country: map['country'] as String? ?? '',
      latitude: (map['latitude'] as num).toDouble(),
      longitude: (map['longitude'] as num).toDouble(),
      territoryId: map['territory_id'] as int?,
      polygonId: map['polygon_id'] as int?,
      orgId: map['org_id'] as int,
      comments: map['comments'] as String? ?? '',
    );
  }
}

class LeadsDetailsModel extends LeadsDetailsEntity {
  const LeadsDetailsModel({
    required super.addressId,
    required super.contactName,
    required super.contactPhone,
    required super.leadID,
    required super.leadName,
    required super.leadAddress,
    required super.contactEmail,
    required super.pendingAssignment,
    required super.status,
  });

  factory LeadsDetailsModel.fromMap(DataMap map) {
    return LeadsDetailsModel(
      addressId: map['address_id'] as int? ?? 0,
      contactName: map['contact_name'] as String? ?? "",
      contactPhone: map['contact_phone'] as String? ?? "",
      leadID: map['lead_id'] as int,
      leadName: map['name'] as String? ?? "",
      leadAddress: map['address'] == null
          ? LeadsAddressModel.empty()
          : LeadsAddressModel.fromMap(map['address'] as DataMap),
      pendingAssignment: map['pending_assignment'] as bool? ?? false,
      contactEmail: map['contact_email'] as String? ?? "",
      status: map['status'] as String? ?? "",
    );
  }
}
