import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/usecases/add_lead.dart';
import 'package:track/src/features/visits/domain/usecases/get_all_leads.dart';

part 'add_lead_state.dart';

class AddLeadCubit extends Cubit<AddLeadState> {
  final AddLead addLead;
  final GetAllLeads getAllLeads;
  AddLeadCubit(this.addLead, this.getAllLeads) : super(AddLeadInitial());

  Future<bool> _checkDuplicateLead(String email, String phone) async {
    try {
      final res = await getAllLeads(
        GetAllLeadsParams(pageNumber: 1, limit: 100, query: email),
      );
      return res.fold(
        (failure) => false,
        (leadsData) {
          return leadsData.allLeads.any((lead) => 
            lead.contactEmail.toLowerCase() == email.toLowerCase() ||
            lead.contactPhone == phone
          );
        },
      );
    } catch (e) {
      return false;
    }
  }

  Future addTheLead({
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
    emit(AddLeadLoading());
    
    // Check for duplicates first
    final isDuplicate = await _checkDuplicateLead(contactEmail, contactPhone);
    if (isDuplicate) {
      emit(AddLeadFailed("Lead with this email or phone number already exists"));
      return;
    }
    
    final res = await addLead(
      AddLeadParams(
        name: name,
        contactName: contactName,
        contactEmail: contactEmail,
        contactPhone: contactPhone,
        streetAddress: streetAddress,
        city: city,
        state: state,
        postalCode: postalCode,
        areaName: areaName,
        subregion: subregion,
        region: region,
        country: country,
      ),
    );
    res.fold(
      (failure) {
        emit(AddLeadFailed(failure.message));
      },
      (_) {
        emit(AddLeadSuccess());
      },
    );
  }
}
