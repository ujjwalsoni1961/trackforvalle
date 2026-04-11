import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/usecases/update_lead_details.dart';

part 'edit_a_lead_details_state.dart';

class EditALeadDetailsCubit extends Cubit<EditALeadDetailsState> {
  final UpdateLeadDetails updateLeadDetails;
  EditALeadDetailsCubit(this.updateLeadDetails)
    : super(EditALeadDetailsInitial());

  void updateTheLeadDetails({
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
    emit(EditALeadDetailsLoading());
    if (contactName == null &&
        contactEmail == null &&
        contactPhone == null &&
        streetAddress == null &&
        postalCode == null &&
        areaName == null &&
        subregion == null &&
        region == null &&
        country == null &&
        status == null) {
      emit(EditALeadDetailsFailed("One value must be updated."));
      return;
    }
    final res = await updateLeadDetails(
      UpdateLeadDetailsParams(
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
      ),
    );
    res.fold(
      (failure) {
        emit(EditALeadDetailsFailed(failure.message));
      },
      (leadDetails) {
        emit(EditALeadDetailsSuccess(leadDetails));
      },
    );
  }
}
