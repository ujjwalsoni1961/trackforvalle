import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/usecases/plan_visits.dart';

part 'plan_visits_state.dart';

class PlanVisitsCubit extends Cubit<PlanVisitsState> {
  final PlanVisits planVisits;
  PlanVisitsCubit(this.planVisits) : super(PlanVisitsInitial());

  Future<void> planTheVisit({
    required double latitude,
    required double longitude,
    required List<int> leadIds,
  }) async {
    // Google Maps Directions API allows maximum 25 waypoints
    // (23 waypoints + origin + destination)
    const int maxWaypoints = 23;

    if (leadIds.length > maxWaypoints) {
      emit(
        PlanVisitsFailed(
          'Cannot plan more than $maxWaypoints visits at once due to Google Maps API limitations. '
          'You have selected ${leadIds.length} leads. Please select fewer leads or split them into multiple routes.',
        ),
      );
      return;
    }

    emit(PlanVisitsLoading());
    final res = await planVisits(
      PlanVisitsParams(
        latitude: latitude,
        longitude: longitude,
        leadIds: leadIds,
      ),
    );
    res.fold(
      (failure) => emit(PlanVisitsFailed(failure.message)),
      (_) => emit(PlanVisitsSuccess()),
    );
  }
}
