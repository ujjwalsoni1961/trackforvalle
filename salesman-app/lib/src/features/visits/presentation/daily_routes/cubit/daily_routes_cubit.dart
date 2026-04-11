import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_entity.dart';
import 'package:track/src/features/visits/domain/entities/refresh_routes_entity.dart';
import 'package:track/src/features/visits/domain/usecases/get_routes.dart';
import 'package:track/src/features/visits/domain/usecases/get_updated_routes.dart';

part 'daily_routes_state.dart';

class DailyRoutesCubit extends Cubit<DailyRoutesState> {
  final GetRoutes getRoutes;
  final GetUpdatedRoutes getUpdatedRoutes;
  DailyRoutesCubit(this.getRoutes, this.getUpdatedRoutes)
    : super(DailyRoutesInitial());

  bool isRoutesRefreshed = false;

  List<DailyRoutesEntity> sortAndUpdateRoutes(
    List<DailyRoutesEntity> dailyRoutes,
    List<RefreshRoutesEntity> refreshRoutes,
  ) {
    List<int> visitIDs = refreshRoutes.map((e) => e.visitID).toList();
    dailyRoutes.sort((a, b) {
      int indexA = visitIDs.indexOf(a.visitID);
      int indexB = visitIDs.indexOf(b.visitID);
      return indexA.compareTo(indexB);
    });
    return dailyRoutes;
  }

  Future<void> getTheRoutes({double? latitude, double? longitude}) async {
    emit(DailyRoutesLoading());
    final res = await getRoutes();
    res.fold(
      (failure) {
        emit(DailyRoutesFailed(errorMessage: failure.message));
      },
      (routes) async {
        if (routes.routes.isEmpty) {
          emit(DailyRoutesFailed(errorMessage: "No visits found for today..."));
          return;
        }
        if (latitude == null && longitude == null) {
          emit(
            DailyRefreshRouteFailed(
              errorMessage:
                  "Failed to Optimize daily routes, couldn't fetch current location (check permissions/settings).",
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          emit(DailyRoutesLoaded(routes: routes.routes));
          return;
        }
        if (latitude != null && longitude != null) {
          refreshTheRoutes(
            latitude: latitude,
            longitude: longitude,
            unOptimizedRoutes: routes.routes,
          );
        }
      },
    );
  }

  void refreshTheRoutes({
    required double latitude,
    required double longitude,
    required List<DailyRoutesEntity> unOptimizedRoutes,
  }) async {
    emit(DailyRefreshRouteLoading());
    final resUpdatedRoutes = await getUpdatedRoutes(
      GetUpdatedRoutesParams(latitude: latitude, longitude: longitude),
    );
    resUpdatedRoutes.fold(
      (failure) async {
        emit(DailyRefreshRouteFailed(errorMessage: failure.message));
        await Future.delayed(const Duration(milliseconds: 300));
        emit(DailyRoutesLoaded(routes: unOptimizedRoutes));
      },
      (updatedRoutes) async {
        try {
          List<DailyRoutesEntity> sortedRoutes = sortAndUpdateRoutes(
            unOptimizedRoutes,
            updatedRoutes.updatedRoutes,
          );
          isRoutesRefreshed = true;
          emit(DailyRoutesLoaded(routes: sortedRoutes));
        } catch (e) {
          emit(
            DailyRefreshRouteFailed(
              errorMessage:
                  "Failed to refresh route, showing un-optimized routes...",
            ),
          );
          await Future.delayed(const Duration(milliseconds: 300));
          emit(DailyRoutesLoaded(routes: unOptimizedRoutes));
        }
      },
    );
  }
}
