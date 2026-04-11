import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/repositories/leads_repository.dart';

class UpdateLeadDetails
    extends UseCaseWithParams<LeadsDetailsEntity, UpdateLeadDetailsParams> {
  final LeadsRepository _repository;

  const UpdateLeadDetails(LeadsRepository repository)
    : _repository = repository;

  @override
  ResultFuture<LeadsDetailsEntity> call(UpdateLeadDetailsParams params) async =>
      await _repository.updateLeadDetails(
        leadID: params.leadID,
        contactName: params.contactName,
        contactEmail: params.contactEmail,
        contactPhone: params.contactPhone,
        streetAddress: params.streetAddress,
        postalCode: params.postalCode,
        areaName: params.areaName,
        subregion: params.subregion,
        region: params.region,
        country: params.country,
        status: params.status,
      );
}

class UpdateLeadDetailsParams extends Equatable {
  final int leadID;
  final String? contactName;
  final String? contactEmail;
  final String? contactPhone;
  final String? streetAddress;
  final String? postalCode;
  final String? areaName;
  final String? subregion;
  final String? region;
  final String? country;
  final String? status;

  const UpdateLeadDetailsParams({
    required this.leadID,
    this.contactEmail,
    this.contactPhone,
    this.streetAddress,
    this.postalCode,
    this.areaName,
    this.subregion,
    this.region,
    this.country,
    this.status,
    this.contactName,
  });

  @override
  List<Object?> get props => [
    leadID,
    contactName,
    contactEmail,
    contactPhone,
    streetAddress,
    postalCode,
    areaName,
    subregion,
    region,
    country,
    status,
  ];
}
