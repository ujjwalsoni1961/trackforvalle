import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_past_visits.dart';

part 'past_visits_state.dart';

class PastVisitsCubit extends Cubit<PastVisitsState> {
  final GetPastVisits getPastVisits;
  PastVisitsCubit(this.getPastVisits) : super(PastVisitsInitial());

  PastVisitsListEntity pastVisits = PastVisitsListEntity.empty();

  Future<void> getGeneralPastVisits({
    String? leadStatus,
    int pageNumber = 1,
    int limit = 10,
  }) async {
    if (pageNumber > 1 &&
        pastVisits.pagination.totalPages > 0 &&
        pageNumber > pastVisits.pagination.totalPages) {
      return;
    }

    if (pageNumber > 1) {
      emit(PastVisitsLoading(false));
    } else {
      emit(PastVisitsLoading(true));
    }
    final result = await getPastVisits(
      PastVisitsParams(
        leadStatus: leadStatus,
        limit: limit,
        pageNumber: pageNumber,
      ),
    );

    result.fold((failure) => emit(PastVisitsFailed(failure.message)), (visits) {
      List<PastVisitItemEntity> allVisits;

      if (pageNumber == 1) {
        allVisits = List<PastVisitItemEntity>.from(visits.visits);
      } else {
        allVisits = List<PastVisitItemEntity>.from(pastVisits.visits);
        allVisits.addAll(visits.visits);
      }

      pastVisits = PastVisitsListEntity(
        visits: allVisits,
        pagination: visits.pagination,
      );

      emit(PastVisitsSuccess(pastVisits.visits, visits.pagination));
    });
  }
}
