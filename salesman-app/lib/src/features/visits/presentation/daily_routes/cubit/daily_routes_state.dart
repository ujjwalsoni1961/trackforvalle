part of 'daily_routes_cubit.dart';

sealed class DailyRoutesState extends Equatable {
  const DailyRoutesState();

  @override
  List<Object> get props => [];
}

final class DailyRoutesInitial extends DailyRoutesState {}

final class DailyRoutesLoading extends DailyRoutesInitial {}

final class DailyRoutesLoaded extends DailyRoutesInitial {
  final List<DailyRoutesEntity> routes;
  DailyRoutesLoaded({required this.routes});

  @override
  List<Object> get props => [routes];
}

final class DailyRoutesFailed extends DailyRoutesInitial {
  final String errorMessage;
  DailyRoutesFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

final class DailyRefreshRouteLoading extends DailyRoutesInitial {}

final class DailyRefreshRouteFailed extends DailyRoutesInitial {
  final String errorMessage;
  DailyRefreshRouteFailed({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
