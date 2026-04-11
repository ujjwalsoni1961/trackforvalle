import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/ui/utility/center_loading_text_widget.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/center_error_widget.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/location_permission_widget.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/daily_routes_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/get_current_location_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/widgets/routes_list_widget.dart';
import 'package:track/src/features/visits/presentation/daily_routes/widgets/routes_map_view.dart';

class DailyRoutesView extends StatefulWidget {
  const DailyRoutesView({super.key});

  @override
  State<DailyRoutesView> createState() => _DailyRoutesViewState();
}

class _DailyRoutesViewState extends State<DailyRoutesView> {
  late DailyRoutesCubit dailyRoutesCubit = context.read<DailyRoutesCubit>();
  late GetCurrentLocationCubit getCurrentLocationCubit = context
      .read<GetCurrentLocationCubit>();

  late ThemeData theme = Theme.of(context);
  bool isMapView = false;

  Widget currentLocationStringWidget() {
    return BlocBuilder<GetCurrentLocationCubit, GetCurrentLocationState>(
      builder: (context, state) {
        if (state is GetCurrentLocationSuccess) {
          return Container(
            width: double.infinity,
            color: theme.colorScheme.primary.withOpacity(0.08),
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    state.currentLocation, // sample string
                    style: theme.textTheme.bodyMedium,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        }
        return SizedBox();
      },
    );
  }

  Widget _buildActionItem({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70.0,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.0, color: theme.colorScheme.primary),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.0,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GetCurrentLocationCubit, GetCurrentLocationState>(
      listener: (context, locationState) {
        // Handle location state changes
        if (locationState is GetCurrentLocationPermissionDenied) {
          if (locationState.isPermanentlyDenied) {
            context.errorBar(
              'Location permission permanently denied. Please enable in settings.',
            );
          }
        }
        if (locationState is GetCurrentLocationServiceDisabled) {
          context.errorBar('Please enable location services');
        }
      },
      builder: (context, locationState) {
        // Show location permission request if permission is denied
        if (locationState is GetCurrentLocationPermissionDenied) {
          return LocationPermissionWidget(
            onPermissionGranted: () {
              getCurrentLocationCubit.getCurrentLatLong(refreshRoutes: true);
            },
            title: 'Location Access Required',
            description:
                'We need your location to show optimized daily routes and nearby leads.',
            showAppSettingsButton: locationState.isPermanentlyDenied,
          );
        }

        // Show location service disabled message
        if (locationState is GetCurrentLocationServiceDisabled) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.location_off,
                    size: 64,
                    color: theme.colorScheme.error,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Location Services Disabled',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please enable location services in your device settings.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () {
                      getCurrentLocationCubit.getCurrentLatLong(
                        refreshRoutes: true,
                      );
                    },
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            ),
          );
        }

        // Show daily routes content based on routes cubit state
        return BlocConsumer<DailyRoutesCubit, DailyRoutesState>(
          listener: (context, state) {
            if (state is DailyRefreshRouteFailed) {
              context.errorBar(state.errorMessage);
            }
            if (state is DailyRoutesFailed) {
              context.errorBar(state.errorMessage);
            }
          },
          builder: (context, state) {
            if (state is DailyRoutesFailed) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CenterErrorWidget(error: state.errorMessage),
                  TextButton.icon(
                    onPressed: () {
                      getCurrentLocationCubit.getCurrentLatLong(
                        refreshRoutes: true,
                      );
                    },
                    label: Text("Retry?"),
                    icon: Icon(Icons.refresh_outlined),
                  ),
                ],
              );
            }
            if (state is DailyRoutesLoading) {
              return CenterLoadingTextWidget(
                  text: "Loading your daily routes...");
            }
            if (state is DailyRefreshRouteLoading) {
              return CenterLoadingTextWidget(
                text: "Optimizing your daily routes...",
              );
            }
            if (state is DailyRoutesLoaded) {
              return Column(
                children: [
                  currentLocationStringWidget(),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 8.0,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isMapView = false;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: !isMapView
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('List View'),
                        ),
                        const GapH(6.0),
                        OutlinedButton(
                          onPressed: () {
                            setState(() {
                              isMapView = true;
                            });
                          },
                          style: OutlinedButton.styleFrom(
                            backgroundColor: isMapView
                                ? theme.colorScheme.primary.withOpacity(0.1)
                                : Colors.transparent,
                            side: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 1.0,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16.0,
                              vertical: 6.0,
                            ),
                            textStyle: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          child: const Text('Map View'),
                        ),
                        const Spacer(),
                        _buildActionItem(
                          onPressed: () async {
                            await getCurrentLocationCubit.getCurrentLatLong();
                            dailyRoutesCubit.getTheRoutes(
                              latitude: getCurrentLocationCubit.latitude ?? 0,
                              longitude: getCurrentLocationCubit.longitude ?? 0,
                            );
                          },
                          icon: Icons.refresh_outlined,
                          label: "Refresh",
                        ),
                        const GapH(8.0),
                        _buildActionItem(
                          onPressed: () async {
                            await getCurrentLocationCubit.getCurrentLatLong();
                            if (getCurrentLocationCubit.latitude != null &&
                                getCurrentLocationCubit.longitude != null) {
                              dailyRoutesCubit.refreshTheRoutes(
                                latitude: getCurrentLocationCubit.latitude!,
                                longitude: getCurrentLocationCubit.longitude!,
                                unOptimizedRoutes: state.routes,
                              );
                            }
                          },
                          icon: Icons.route_outlined,
                          label: "Optimize",
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: isMapView
                        ? DailyRoutesMapWidget(routes: state.routes)
                        : DailyRoutesListWidget(routes: state.routes),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        );
      },
    );
  }
}
