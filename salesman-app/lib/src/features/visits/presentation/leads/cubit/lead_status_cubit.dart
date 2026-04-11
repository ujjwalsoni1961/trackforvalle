import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_lead_status_list.dart';

part 'lead_status_state.dart';

class LeadStatusCubit extends Cubit<LeadStatusState> {
  final GetLeadStatusList getLeadStatusList;
  LeadStatusCubit(this.getLeadStatusList) : super(LeadStatusInitial());

  List<LeadStatusEntity> leadStatusList = [];

  String getColorByLeadStatus(String statusToFind) {
    for (final status in leadStatusList) {
      if (status.status == statusToFind) {
        return status.hexColor;
      }
    }
    return "#ff6c37";
  }

  void getTheLeadStatusList() async {
    emit(LeadStatusLoading());
    final res = await getLeadStatusList();
    res.fold((failure) => emit(LeadStatusFailed(failure.message)), (
      statusList,
    ) {
      leadStatusList = statusList.statusList;
      emit(LeadStatusSuccess(statusList.statusList));
    });
  }
}
