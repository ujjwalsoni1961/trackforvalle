import 'package:dartz/dartz.dart';
import 'package:track/src/core/errors/exceptions.dart';
import 'package:track/src/core/errors/failure.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/features/visits/data/data_sources/leads_remote_data_source.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/entities/leads_list_entity.dart';
import 'package:track/src/features/visits/domain/repositories/leads_repository.dart';

class LeadsRepositoryImpl extends LeadsRepository {
  final LeadsRemoteDataSource _remoteDataSource;

  LeadsRepositoryImpl(LeadsRemoteDataSource remoteDataSource)
    : _remoteDataSource = remoteDataSource;

  @override
  ResultFuture<LeadsListEntity> getLeads({
    required int pageNumber,
    required int limit,
    String? query,
  }) async {
    try {
      final allLeadsData = await _remoteDataSource.getLeads(
        pageNumber: pageNumber,
        limit: limit,
        query: query,
      );
      return Right(allLeadsData);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
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
  }) async {
    try {
      final updatedLead = await _remoteDataSource.updateLeadDetails(
        leadID: leadID,
        contactName: contactName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        streetAddress: streetAddress,
        postalCode: postalCode,
        areaName: areaName,
        subregion: subregion,
        region: region,
        country: country,
        status: status,
      );
      return Right(updatedLead);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
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
  }) async {
    try {
      final updatedLead = await _remoteDataSource.addLead(
        name: name,
        contactName: contactName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        streetAddress: streetAddress,
        postalCode: postalCode,
        areaName: areaName,
        subregion: subregion,
        region: region,
        country: country,
        city: city,
        state: state,
      );
      return Right(updatedLead);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }

  @override
  ResultFuture<LeadStatusListEntity> getLeadStatusList() async {
    try {
      final allStatusList = await _remoteDataSource.getLeadStatusList();
      return Right(allStatusList);
    } on APIException catch (e) {
      return Left(APIFailure.fromAPIException(e));
    }
  }
}
