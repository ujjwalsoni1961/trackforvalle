import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/repositories/leads_repository.dart';

class AddLead extends UseCaseWithParams<void, AddLeadParams> {
  final LeadsRepository _repository;

  const AddLead(LeadsRepository repository) : _repository = repository;

  @override
  ResultFutureVoid call(AddLeadParams params) async =>
      await _repository.addLead(
        contactName: params.contactName,
        contactEmail: params.contactEmail,
        contactPhone: params.contactPhone,
        streetAddress: params.streetAddress,
        postalCode: params.postalCode,
        areaName: params.areaName,
        subregion: params.subregion,
        region: params.region,
        country: params.country,
        city: params.city,
        state: params.state,
        name: params.name,
      );
}

class AddLeadParams extends Equatable {
  final String name;
  final String contactName;
  final String contactEmail;
  final String contactPhone;
  final String streetAddress;
  final String city;
  final String state;
  final String postalCode;
  final String areaName;
  final String subregion;
  final String region;
  final String country;

  const AddLeadParams({
    required this.name,
    required this.contactName,
    required this.contactEmail,
    required this.contactPhone,
    required this.streetAddress,
    required this.city,
    required this.state,
    required this.postalCode,
    required this.areaName,
    required this.subregion,
    required this.region,
    required this.country,
  });

  @override
  List<Object> get props => [
    name,
    contactName,
    contactEmail,
    contactPhone,
    streetAddress,
    city,
    state,
    postalCode,
    areaName,
    subregion,
    region,
    country,
  ];
}
