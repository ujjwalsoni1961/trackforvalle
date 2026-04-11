part of 'dashboard_cubit.dart';

sealed class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object> get props => [];
}

final class DashboardInitial extends DashboardState {}

final class DashboardLoading extends DashboardState {}

final class DashboardSuccess extends DashboardState {
  final DashboardDataEntity dashboardData;

  const DashboardSuccess(this.dashboardData);

  @override
  List<Object> get props => [dashboardData];
}

final class DashboardFailed extends DashboardState {
  final String errorMessage;

  const DashboardFailed(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
