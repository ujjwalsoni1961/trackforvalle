import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/features/dashboard/domain/entities/dashboard_entity.dart';
import 'package:track/src/features/dashboard/domain/usecases/get_dashboard_data.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final GetDashboardData getDashboardData;
  DashboardCubit(this.getDashboardData) : super(DashboardInitial());

  Future<void> getTheDashBoardData() async {
    emit(DashboardLoading());
    final result = await getDashboardData();
    result.fold(
      (failure) => emit(DashboardFailed(failure.message)),
      (dashboardData) => emit(DashboardSuccess(dashboardData)),
    );
  }
}
