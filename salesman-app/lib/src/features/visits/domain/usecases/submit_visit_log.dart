import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:track/src/core/utils/typedef.dart';
import 'package:track/src/core/utils/usecase.dart';
import 'package:track/src/features/visits/domain/repositories/visits_repository.dart';

class SubmitVisitLog extends UseCaseWithParams<void, SubmitVisitLogParams> {
  final VisitsRepository _repository;

  SubmitVisitLog(VisitsRepository repository) : _repository = repository;

  @override
  ResultFutureVoid call(SubmitVisitLogParams params) async =>
      await _repository.submitVisitLog(
        photos: params.photos,
        notes: params.notes,
        latitude: params.latitude,
        longitude: params.longitude,
        visitID: params.visitID,
        leadID: params.leadID,
        followUp: params.followUp,
        contractID: params.contractID,
        leadStatus: params.leadStatus,
      );
}

class SubmitVisitLogParams extends Equatable {
  final List<File> photos;
  final String notes;
  final double latitude;
  final double longitude;
  final int leadID;
  final String? followUp;
  final int? contractID;
  final int? visitID;
  final String leadStatus;

  const SubmitVisitLogParams({
    required this.photos,
    required this.notes,
    required this.latitude,
    required this.longitude,
    required this.leadID,
    required this.leadStatus,
    this.followUp,
    this.visitID,
    this.contractID,
  });

  @override
  List<Object?> get props => [
    photos,
    notes,
    latitude,
    longitude,
    leadID,
    followUp,
    leadStatus,
    visitID,
    contractID,
  ];
}
