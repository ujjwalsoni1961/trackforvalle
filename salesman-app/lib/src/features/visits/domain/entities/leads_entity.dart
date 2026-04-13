import 'package:equatable/equatable.dart';

class LeadsAddressEntity extends Equatable {
  final int addressId;
  final String streetAddress;
  final String buildingUnit;
  final String landmark;
  final String city;
  final String state;
  final String postalCode;
  final String areaName;
  final String subregion;
  final String region;
  final String country;
  final double latitude;
  final double longitude;
  final int? territoryId;
  final int? polygonId;
  final int orgId;
  final String comments;

  const LeadsAddressEntity({
    required this.addressId,
    required this.streetAddress,
    required this.buildingUnit,
    required this.landmark,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.areaName,
    required this.subregion,
    required this.region,
    required this.country,
    required this.latitude,
    required this.longitude,
    this.territoryId,
    this.polygonId,
    required this.orgId,
    this.comments = '',
  });

  factory LeadsAddressEntity.empty() {
    return LeadsAddressEntity(
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
      territoryId: null,
      polygonId: null,
      orgId: 0,
      comments: '',
    );
  }

  @override
  List<Object?> get props => [
    addressId,
    streetAddress,
    buildingUnit,
    landmark,
    city,
    state,
    postalCode,
    areaName,
    subregion,
    region,
    country,
    latitude,
    longitude,
    territoryId,
    polygonId,
    orgId,
    comments,
  ];
}

class LeadsDetailsEntity extends Equatable {
  final int leadID;
  final int addressId;
  final String leadName;
  final LeadsAddressEntity leadAddress;
  final String contactName;
  final String contactPhone;
  final String contactEmail;
  final bool pendingAssignment;
  final String status;

  const LeadsDetailsEntity({
    required this.leadID,
    required this.addressId,
    required this.leadName,
    required this.contactName,
    required this.contactPhone,
    required this.contactEmail,
    required this.status,
    required this.leadAddress,
    required this.pendingAssignment,
  });

  factory LeadsDetailsEntity.empty() {
    return LeadsDetailsEntity(
      leadID: 0,
      addressId: 0,
      leadName: '',
      contactName: '',
      contactPhone: '',
      contactEmail: '',
      status: '',
      leadAddress: LeadsAddressEntity.empty(),
      pendingAssignment: false,
    );
  }

  @override
  List<Object?> get props => [
    leadID,
    addressId,
    leadName,
    contactName,
    contactPhone,
    contactEmail,
    status,
    leadAddress,
    pendingAssignment,
  ];
}
