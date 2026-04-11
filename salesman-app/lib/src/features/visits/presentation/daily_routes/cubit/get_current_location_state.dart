part of 'get_current_location_cubit.dart';

sealed class GetCurrentLocationState extends Equatable {
  const GetCurrentLocationState();

  @override
  List<Object> get props => [];
}

final class GetCurrentLocationInitial extends GetCurrentLocationState {}

final class GetCurrentLocationLoading extends GetCurrentLocationState {
  final bool refreshRoutes;

  const GetCurrentLocationLoading({this.refreshRoutes = false});

  @override
  List<Object> get props => [refreshRoutes];
}

final class GetCurrentLocationSuccess extends GetCurrentLocationState {
  final double latitude;
  final double longitude;
  final String currentLocation;
  final bool refreshRoutes;

  const GetCurrentLocationSuccess({
    required this.latitude,
    required this.longitude,
    required this.currentLocation,
    this.refreshRoutes = false,
  });

  @override
  List<Object> get props => [latitude, longitude, refreshRoutes];
}

final class GetCurrentLocationFailed extends GetCurrentLocationState {
  final String errorMessage;
  final bool refreshRoutes;

  const GetCurrentLocationFailed({
    required this.errorMessage,
    this.refreshRoutes = false,
  });

  @override
  List<Object> get props => [errorMessage, refreshRoutes];
}

/// State when location permission is denied
final class GetCurrentLocationPermissionDenied extends GetCurrentLocationState {
  final bool isPermanentlyDenied;
  final bool refreshRoutes;

  const GetCurrentLocationPermissionDenied({
    this.isPermanentlyDenied = false,
    this.refreshRoutes = false,
  });

  @override
  List<Object> get props => [isPermanentlyDenied, refreshRoutes];
}

/// State when location service is disabled
final class GetCurrentLocationServiceDisabled extends GetCurrentLocationState {
  final bool refreshRoutes;

  const GetCurrentLocationServiceDisabled({
    this.refreshRoutes = false,
  });

  @override
  List<Object> get props => [refreshRoutes];
}
