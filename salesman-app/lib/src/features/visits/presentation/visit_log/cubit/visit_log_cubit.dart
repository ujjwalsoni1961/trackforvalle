import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/usecases/submit_visit_log.dart';

part 'visit_log_state.dart';

class VisitLogCubit extends Cubit<VisitLogState> {
  final SubmitVisitLog submitVisitLog;
  VisitLogCubit(this.submitVisitLog) : super(VisitLogInitial());

  Map<int, int> savedContractIDsByLeadID = {};
  Map<int, int> savedVisitIdsbyLeadID = {};

  void setContractID({required int leadID, required int contractID}) {
    savedContractIDsByLeadID[leadID] = contractID;
  }

  void setVisitID({required int leadID, required int visitID}) {
    savedVisitIdsbyLeadID[leadID] = visitID;
  }

  void submitTheVisitLog({
    required List<File> photos,
    required String notes,
    required double latitude,
    required double longitude,
    required int leadID,
    int? visitID,
    required String leadStatus,
    String? followUp,
    int? contractID,
  }) async {
    emit(VisitLogLoading());
    final res = await submitVisitLog(
      SubmitVisitLogParams(
        photos: photos,
        notes: notes,
        latitude: latitude,
        longitude: longitude,
        leadID: leadID,
        visitID: visitID,
        followUp: followUp,
        contractID: contractID,
        leadStatus: leadStatus,
      ),
    );

    res.fold(
      (failure) => emit(VisitLogFailed(failure.message)),
      (_) => emit(VisitLogSuccess(leadID: leadID, leadStatus: leadStatus)),
    );
  }
}
