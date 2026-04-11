import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';

part 'get_current_location_state.dart';

class GetCurrentLocationCubit extends Cubit<GetCurrentLocationState> {
  GetCurrentLocationCubit() : super(GetCurrentLocationInitial());

  double? latitude, longitude;

  Future<String> getCurrentLocationString({
    required double latitude,
    required double longitude,
  }) async {
    String locationName = "Couldn't fetch location details";
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(
        latitude,
        longitude,
      );
      if (placemarks.isNotEmpty) {
        final placemark = placemarks.first;
        locationName = [
          placemark.street,
          placemark.locality,
          placemark.administrativeArea,
          placemark.country,
        ].where((e) => e != null && e.isNotEmpty).join(', ');
      }

      return locationName;
    } catch (e) {
      debugPrint(e.toString());
    }
    return locationName;
  }

  Future<void> getCurrentLatLong({bool refreshRoutes = false}) async {
    emit(GetCurrentLocationLoading(refreshRoutes: refreshRoutes));
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        emit(GetCurrentLocationServiceDisabled(refreshRoutes: refreshRoutes));
        return;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          emit(GetCurrentLocationPermissionDenied(
            isPermanentlyDenied: false,
            refreshRoutes: refreshRoutes,
          ));
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        emit(GetCurrentLocationPermissionDenied(
          isPermanentlyDenied: true,
          refreshRoutes: refreshRoutes,
        ));
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      latitude = position.latitude;
      longitude = position.longitude;

      String locationName = await getCurrentLocationString(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      emit(
        GetCurrentLocationSuccess(
          latitude: position.latitude,
          longitude: position.longitude,
          refreshRoutes: refreshRoutes,
          currentLocation: locationName,
        ),
      );
    } catch (e) {
      emit(
        GetCurrentLocationFailed(
          errorMessage: e.toString(),
          refreshRoutes: refreshRoutes,
        ),
      );
    }
  }

  /// Check if location permission is granted
  Future<bool> hasLocationPermission() async {
    try {
      final permission = await Geolocator.checkPermission();
      return permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always;
    } catch (e) {
      debugPrint('Error checking location permission: $e');
      return false;
    }
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      debugPrint('Error checking location service: $e');
      return false;
    }
  }
}
