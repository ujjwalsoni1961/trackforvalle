import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_past_visits.dart';

part 'lead_id_past_visits_state.dart';

class LeadIdPastVisitsCubit extends Cubit<LeadIdPastVisitsState> {
  final GetPastVisits getPastVisits;

  LeadIdPastVisitsCubit(this.getPastVisits) : super(LeadIdPastVisitsInitial());
  PastVisitsListEntity leadIDPastVisits = PastVisitsListEntity.empty();

  Future<void> getLeadPastVisits({
    required int leadID,
    String? leadStatus,
    int pageNumber = 1,
    int limit = 5,
  }) async {
    if (pageNumber > 1 &&
        leadIDPastVisits.pagination.totalPages > 0 &&
        pageNumber > leadIDPastVisits.pagination.totalPages) {
      return;
    }

    if (pageNumber > 1) {
      emit(LeadIDPastVisitsLoading(false));
    } else {
      emit(LeadIDPastVisitsLoading(true));
    }

    final result = await getPastVisits(
      PastVisitsParams(
        leadID: leadID,
        leadStatus: leadStatus,
        limit: limit,
        pageNumber: pageNumber,
      ),
    );

    result.fold((failure) => emit(LeadIDPastVisitsFailed(failure.message)), (
      visits,
    ) {
      List<PastVisitItemEntity> allVisits;

      if (pageNumber == 1) {
        allVisits = List<PastVisitItemEntity>.from(visits.visits);
      } else {
        allVisits = List<PastVisitItemEntity>.from(leadIDPastVisits.visits);
        allVisits.addAll(visits.visits);
      }

      leadIDPastVisits = PastVisitsListEntity(
        visits: allVisits,
        pagination: visits.pagination,
      );

      emit(LeadIDPastVisitsSuccess(leadIDPastVisits.visits, visits.pagination));
    });
  }
}
