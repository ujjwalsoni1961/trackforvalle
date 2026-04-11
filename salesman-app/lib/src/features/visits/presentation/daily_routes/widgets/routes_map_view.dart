// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_entity.dart';
import 'package:track/src/features/visits/presentation/daily_routes/widgets/route_card.dart';
import 'dart:ui' as ui;
import 'dart:math';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';

class DailyRoutesMapWidget extends StatefulWidget {
  final List<DailyRoutesEntity> routes;

  const DailyRoutesMapWidget({super.key, required this.routes});

  @override
  State<DailyRoutesMapWidget> createState() => _DailyRoutesMapWidgetState();
}

class _DailyRoutesMapWidgetState extends State<DailyRoutesMapWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  Set<Polyline> _polylines = {};
  DailyRoutesEntity? _selectedRoute;
  bool _isMapReady = false;
  bool _isCreatingMarkers = false;
  bool _showRoutes = false;
  MapType _currentMapType = MapType.normal;
  LatLng? _currentLocation;

  final Map<String, BitmapDescriptor> _markerIconCache = {};

  late LeadStatusCubit leadStatusCubit = context.read<LeadStatusCubit>();

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _initializeMapData();
  }

  @override
  void didUpdateWidget(DailyRoutesMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.routes != widget.routes) {
      _initializeMapData();
    }
  }

  @override
  void dispose() {
    // Safely dispose the controller only if it's been initialized
    if (_controller != null) {
      try {
        _controller!.dispose();
      } catch (e) {
        debugPrint('Error disposing map controller: $e');
      }
    }
    _markerIconCache.clear();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Location permissions are denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Location permissions are permanently denied.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
      });

      // Recreate routes if they are enabled to include current location
      if (_showRoutes) {
        _createRoutePolylines();
      }
    } catch (e) {
      debugPrint('Error getting current location: $e');
    }
  }

  Future<void> _initializeMapData() async {
    if (_isCreatingMarkers) return;

    setState(() {
      _isCreatingMarkers = true;
    });

    try {
      await _createMarkers();
      if (_showRoutes) {
        await _createRoutePolylines();
      }
    } catch (e) {
      debugPrint('Error creating markers: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isCreatingMarkers = false;
        });
      }
    }
  }

  Future<BitmapDescriptor> _createPointedMarker(
    String status,
    int routeNumber,
    Color markerColor,
  ) async {
    final cacheKey = '${status}_${routeNumber}_${markerColor.value}_${_showRoutes}_${kIsWeb ? 'web' : 'mobile'}';

    if (_markerIconCache.containsKey(cacheKey)) {
      return _markerIconCache[cacheKey]!;
    }

    try {
      // Use smaller pins for web platform
      final double radius = kIsWeb ? 24 : 45;
      final double width = radius * 2;
      final double height = radius * 2.5;

      final pictureRecorder = ui.PictureRecorder();
      final canvas = Canvas(pictureRecorder);

      final fillPaint = Paint()
        ..color = markerColor
        ..style = PaintingStyle.fill
        ..isAntiAlias = true;

      final borderPaint = Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..isAntiAlias = true;

      final shadowPaint = Paint()
        ..color = Colors.black.withOpacity(0.2)
        ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2)
        ..isAntiAlias = true;

      final centerX = width / 2;
      final circleCenterY = radius;

      final path = Path()
        ..addOval(
          Rect.fromCircle(
            center: Offset(centerX, circleCenterY),
            radius: radius,
          ),
        )
        ..moveTo(centerX - radius / 2, circleCenterY + radius)
        ..lineTo(centerX, height)
        ..lineTo(centerX + radius / 2, circleCenterY + radius)
        ..close();

      canvas.save();
      canvas.translate(2, 2);
      canvas.drawPath(path, shadowPaint);
      canvas.restore();

      canvas.drawPath(path, fillPaint);
      canvas.drawPath(path, borderPaint);

      // Show route number when routes are enabled, otherwise show status icon
      if (_showRoutes) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: routeNumber.toString(),
            style: TextStyle(
              fontSize: kIsWeb ? 18 : 34,  // Smaller text for web
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          textDirection: TextDirection.ltr,
        )..layout();

        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            circleCenterY - textPainter.height / 2,
          ),
        );
      } else {
        // Draw status icon
        final icon = _getIconForStatus(status);
        
        // Create a TextSpan with the icon
        final iconSpan = TextSpan(
          text: String.fromCharCode(icon.codePoint),
          style: TextStyle(
            fontSize: kIsWeb ? 20 : 42,  // Smaller icon for web
            color: Colors.white,
            fontFamily: icon.fontFamily ?? 'MaterialIcons',
            package: icon.fontPackage,
            fontWeight: FontWeight.bold,
          ),
        );
        
        final iconPainter = TextPainter(
          text: iconSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        
        iconPainter.layout();

        // Center the icon
        final iconOffset = Offset(
          centerX - iconPainter.width / 2,
          circleCenterY - iconPainter.height / 2,
        );
        
        iconPainter.paint(canvas, iconOffset);
      }

      final img = await pictureRecorder.endRecording().toImage(
        width.toInt(),
        height.toInt(),
      );

      final data = await img.toByteData(format: ui.ImageByteFormat.png);
      if (data == null) throw Exception('Failed to create marker image data');

      final descriptor = BitmapDescriptor.fromBytes(data.buffer.asUint8List());
      _markerIconCache[cacheKey] = descriptor;
      return descriptor;
    } catch (e) {
      debugPrint('Error creating pointed marker: $e');
      return BitmapDescriptor.defaultMarkerWithHue(
        _getHueFromColor(markerColor),
      );
    }
  }

  IconData _getIconForStatus(String status) {
    // Map common lead statuses to meaningful icons
    switch (status.toLowerCase()) {
      case 'prospect':
      case 'new':
      case 'fresh':
        return Icons.star;
      case 'hot_lead':
      case 'hot lead':
      case 'hot':
        return Icons.whatshot;
      case 'meeting':
      case 'meeting scheduled':
      case 'meeting_scheduled':
      case 'appointment':
        return Icons.event_note;
      case 'get_back':
      case 'get back':
      case 'follow up':
      case 'follow_up':
      case 'callback':
        return Icons.schedule;
      case 'start_signing':
      case 'start signing':
      case 'proposal sent':
      case 'proposal_sent':
      case 'quote sent':
      case 'quote_sent':
        return Icons.edit_document;
      case 'signed':
      case 'converted':
      case 'won':
      case 'closed won':
      case 'closed_won':
        return Icons.task_alt;
      case 'not_interested':
      case 'not interested':
      case 'rejected':
        return Icons.thumb_down;
      case 'not_available':
      case 'not available':
        return Icons.person_off;
      case 'contacted':
      case 'in progress':
      case 'in_progress':
        return Icons.phone_enabled;
      case 'qualified':
      case 'interested':
        return Icons.thumb_up;
      case 'lost':
      case 'closed lost':
      case 'closed_lost':
        return Icons.close_rounded;
      case 'negotiation':
      case 'negotiating':
        return Icons.handshake;
      default:
        return Icons.location_on;
    }
  }

  double _getHueFromColor(Color color) {
    if (color == Colors.red) return BitmapDescriptor.hueRed;
    if (color == Colors.blue) return BitmapDescriptor.hueBlue;
    if (color == Colors.green) return BitmapDescriptor.hueGreen;
    if (color == Colors.orange) return BitmapDescriptor.hueOrange;
    if (color == Colors.purple) return BitmapDescriptor.hueViolet;
    if (color == Colors.teal) return BitmapDescriptor.hueCyan;
    return BitmapDescriptor.hueRed;
  }

  Future<void> _createMarkers() async {
    if (widget.routes.isEmpty) return;

    final List<Marker> markers = [];

    final validRoutes = widget.routes.asMap().entries.where((entry) {
      final route = entry.value;
      return route.latitude >= -90 &&
          route.latitude <= 90 &&
          route.longitude >= -180 &&
          route.longitude <= 180;
    }).toList();

    if (validRoutes.isEmpty) {
      if (mounted) {
        setState(() {
          _markers = <Marker>{};
        });
      }
      return;
    }
    // Get optimized route order for proper numbering
    final optimizedRoutes = _optimizeRoute(validRoutes.map((e) => e.value).toList());
    
    for (int optimizedIndex = 0; optimizedIndex < optimizedRoutes.length; optimizedIndex++) {
      final route = optimizedRoutes[optimizedIndex];

      try {
        final markerColor = Color(
          int.parse(
            leadStatusCubit
                .getColorByLeadStatus(route.leadStatus)
                .replaceFirst('#', '0xff'),
          ),
        );

        final markerIcon = await _createPointedMarker(
          route.leadStatus,
          optimizedIndex + 1, // Use optimized order for numbering
          markerColor,
        );
        final position = LatLng(route.latitude, route.longitude);

        markers.add(
          Marker(
            markerId: MarkerId('route_${route.leadID}'),
            position: position,
            infoWindow: InfoWindow(
              title: '${optimizedIndex + 1}. ${route.address}',
              snippet: 'Route ${optimizedIndex + 1} - Tap for details',
            ),
            onTap: () {
              if (mounted) {
                setState(() {
                  _selectedRoute = route;
                });
              }
            },
            icon: markerIcon,
            anchor: const Offset(0.5, 1.0),
          ),
        );
      } catch (e) {
        debugPrint('Error creating marker for route ${optimizedIndex + 1}: $e');
      }
    }

    // Add current location marker if available
    if (_currentLocation != null) {
      final currentLocationMarker = Marker(
        markerId: const MarkerId('current_location'),
        position: _currentLocation!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(
          title: 'Your Location',
          snippet: 'Current position',
        ),
      );
      markers.add(currentLocationMarker);
    }

    if (mounted) {
      setState(() {
        _markers = markers.toSet();
      });
    }
  }

  LatLngBounds? _getBounds() {
    final validRoutes = widget.routes
        .where(
          (route) =>
              route.latitude >= -90 &&
              route.latitude <= 90 &&
              route.longitude >= -180 &&
              route.longitude <= 180,
        )
        .toList();

    if (validRoutes.isEmpty && _currentLocation == null) {
      return null;
    }

    // Collect all points (routes + current location)
    final List<LatLng> allPoints = [];
    
    // Add current location if available
    if (_currentLocation != null) {
      allPoints.add(_currentLocation!);
    }
    
    // Add all route points
    allPoints.addAll(validRoutes.map(
      (route) => LatLng(route.latitude, route.longitude)
    ));

    if (allPoints.isEmpty) {
      return null;
    }

    if (allPoints.length == 1) {
      final point = allPoints.first;
      const double padding = 0.01;
      return LatLngBounds(
        southwest: LatLng(point.latitude - padding, point.longitude - padding),
        northeast: LatLng(point.latitude + padding, point.longitude + padding),
      );
    }

    double minLat = allPoints.first.latitude;
    double maxLat = allPoints.first.latitude;
    double minLng = allPoints.first.longitude;
    double maxLng = allPoints.first.longitude;

    for (final point in allPoints) {
      minLat = minLat < point.latitude ? minLat : point.latitude;
      maxLat = maxLat > point.latitude ? maxLat : point.latitude;
      minLng = minLng < point.longitude ? minLng : point.longitude;
      maxLng = maxLng > point.longitude ? maxLng : point.longitude;
    }

    const double padding = 0.01;
    return LatLngBounds(
      southwest: LatLng(minLat - padding, minLng - padding),
      northeast: LatLng(maxLat + padding, maxLng + padding),
    );
  }

  Future<void> _fitBounds() async {
    if (_controller == null || !_isMapReady) return;

    final bounds = _getBounds();
    if (bounds == null) return;

    try {
      await _controller!.animateCamera(
        CameraUpdate.newLatLngBounds(bounds, 50),
      );
    } catch (e) {
      debugPrint('Error fitting bounds: $e');
      if (widget.routes.isNotEmpty) {
        final firstRoute = widget.routes.first;
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(firstRoute.latitude, firstRoute.longitude),
            12,
          ),
        );
      }
    }
  }

  void _onMapCreated(GoogleMapController controller) {
    _controller = controller;
    _isMapReady = true;

    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted && _isMapReady) {
        _fitBounds();
      }
    });
  }

  Future<void> _zoomIn() async {
    if (_controller != null && _isMapReady) {
      try {
        await _controller!.animateCamera(CameraUpdate.zoomIn());
      } catch (e) {
        debugPrint('Error zooming in: $e');
      }
    }
  }

  Future<void> _zoomOut() async {
    if (_controller != null && _isMapReady) {
      try {
        await _controller!.animateCamera(CameraUpdate.zoomOut());
      } catch (e) {
        debugPrint('Error zooming out: $e');
      }
    }
  }

  void _closeRouteCard() {
    if (mounted) {
      setState(() {
        _selectedRoute = null;
      });
    }
  }

  // Simple nearest neighbor algorithm for route optimization starting from current location
  List<DailyRoutesEntity> _optimizeRoute(List<DailyRoutesEntity> routes) {
    if (routes.length <= 1) return routes;

    final optimizedRoute = <DailyRoutesEntity>[];
    final remaining = List<DailyRoutesEntity>.from(routes);

    // Use current location as starting point if available, otherwise use first route
    double currentLat, currentLng;
    if (_currentLocation != null) {
      currentLat = _currentLocation!.latitude;
      currentLng = _currentLocation!.longitude;
    } else {
      final first = remaining.removeAt(0);
      optimizedRoute.add(first);
      currentLat = first.latitude;
      currentLng = first.longitude;
    }

    // Find nearest neighbors from current position
    while (remaining.isNotEmpty) {
      DailyRoutesEntity? nearest;
      double minDistance = double.infinity;
      int nearestIndex = -1;

      for (int i = 0; i < remaining.length; i++) {
        final route = remaining[i];
        final distance = _calculateDistance(
          currentLat,
          currentLng,
          route.latitude,
          route.longitude,
        );

        if (distance < minDistance) {
          minDistance = distance;
          nearest = route;
          nearestIndex = i;
        }
      }

      if (nearest != null) {
        optimizedRoute.add(nearest);
        remaining.removeAt(nearestIndex);
        currentLat = nearest.latitude;
        currentLng = nearest.longitude;
      }
    }

    return optimizedRoute;
  }

  // Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final double dLat = _toRadians(lat2 - lat1);
    final double dLon = _toRadians(lon2 - lon1);
    
    final double a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) * cos(_toRadians(lat2)) * sin(dLon / 2) * sin(dLon / 2));
    final double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    
    return earthRadius * c;
  }

  double _toRadians(double degrees) {
    return degrees * (pi / 180);
  }

  Future<void> _createRoutePolylines() async {
    final validRoutes = widget.routes.where((route) =>
        route.latitude >= -90 &&
        route.latitude <= 90 &&
        route.longitude >= -180 &&
        route.longitude <= 180).toList();

    if (validRoutes.isEmpty) {
      if (mounted) {
        setState(() {
          _polylines = <Polyline>{};
        });
      }
      return;
    }

    // Get the same optimized route order that was used for marker creation
    final optimizedRoutes = _optimizeRoute(validRoutes);
    final List<LatLng> polylinePoints = [];

    // Add current location as starting point if available
    if (_currentLocation != null) {
      polylinePoints.add(_currentLocation!);
      debugPrint('Added current location to route: ${_currentLocation!.latitude}, ${_currentLocation!.longitude}');
    }

    // Add all the optimized route points in the correct order
    for (int i = 0; i < optimizedRoutes.length; i++) {
      final route = optimizedRoutes[i];
      final point = LatLng(route.latitude, route.longitude);
      polylinePoints.add(point);
      debugPrint('Added route ${i + 1} to polyline: ${route.latitude}, ${route.longitude} (${route.name})');
    }

    debugPrint('Total polyline points: ${polylinePoints.length}');

    // Only create polyline if we have at least 2 points
    if (polylinePoints.length < 2) {
      if (mounted) {
        setState(() {
          _polylines = <Polyline>{};
        });
      }
      return;
    }

    final polyline = Polyline(
      polylineId: const PolylineId('optimized_daily_route'),
      points: polylinePoints,
      color: Colors.blue,
      width: 4,
      patterns: [PatternItem.dash(20), PatternItem.gap(10)],
      geodesic: true,
      jointType: JointType.round,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
    );

    if (mounted) {
      setState(() {
        _polylines = {polyline};
      });
    }
  }

  void _toggleRoutes() {
    // Clear marker cache first to force regeneration
    _markerIconCache.clear();
    
    setState(() {
      _showRoutes = !_showRoutes;
      if (_showRoutes) {
        _createRoutePolylines();
      } else {
        _polylines = <Polyline>{};
      }
    });
    
    // Recreate markers after state change
    Future.microtask(() => _initializeMapData());
  }

  @override
  Widget build(BuildContext context) {
    if (widget.routes.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No routes available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    DailyRoutesEntity? firstValidRoute;
    for (final route in widget.routes) {
      if (route.latitude >= -90 &&
          route.latitude <= 90 &&
          route.longitude >= -180 &&
          route.longitude <= 180) {
        firstValidRoute = route;
        break;
      }
    }

    firstValidRoute ??= widget.routes.first;

    return Stack(
      children: [
        GoogleMap(
          onMapCreated: _onMapCreated,
          initialCameraPosition: CameraPosition(
            target: LatLng(firstValidRoute.latitude, firstValidRoute.longitude),
            zoom: 15,
          ),
          minMaxZoomPreference: const MinMaxZoomPreference(3.0, 21.0),
          mapType: _currentMapType,
          markers: _markers,
          polylines: _polylines,
          zoomGesturesEnabled: true,
          scrollGesturesEnabled: true,
          tiltGesturesEnabled: true,
          rotateGesturesEnabled: true,
          zoomControlsEnabled: false,
          myLocationEnabled: true,
          myLocationButtonEnabled: true,
          mapToolbarEnabled: false,
          compassEnabled: true,
          trafficEnabled: true,
          buildingsEnabled: true,
          indoorViewEnabled: true,
          liteModeEnabled: false,
        ),

        if (_isCreatingMarkers)
          Container(
            color: Colors.black26,
            child: const Center(
              child: CircularProgressIndicator(backgroundColor: Colors.white),
            ),
          ),

        if (_selectedRoute != null)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: RouteCard(route: _selectedRoute!, onClose: _closeRouteCard),
          ),

        Positioned(
          bottom: 120,
          left: 16,
          child: Column(
            children: [
              FloatingActionButton(
                mini: true,
                onPressed: _zoomIn,
                backgroundColor: Colors.white,
                elevation: 4,
                heroTag: "zoom_in",
                child: Icon(Icons.add, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                onPressed: _zoomOut,
                backgroundColor: Colors.white,
                elevation: 4,
                heroTag: "zoom_out",
                child: Icon(Icons.remove, color: Colors.grey[700]),
              ),
              const SizedBox(height: 8),
              FloatingActionButton(
                mini: true,
                onPressed: _fitBounds,
                backgroundColor: Colors.white,
                elevation: 4,
                heroTag: "fit_bounds",
                child: Icon(Icons.center_focus_strong, color: Colors.grey[700]),
              ),
            ],
          ),
        ),

        // Map controls (right side)
        Positioned(
          bottom: 120,
          right: 16,
          child: Column(
            children: [
              // Route toggle button
              FloatingActionButton(
                mini: true,
                onPressed: _toggleRoutes,
                backgroundColor: _showRoutes ? Colors.blue : Colors.white,
                elevation: 4,
                heroTag: "route_toggle",
                child: Icon(
                  Icons.route,
                  color: _showRoutes ? Colors.white : Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              // Map type toggle button
              FloatingActionButton(
                mini: true,
                onPressed: () {
                  setState(() {
                    _currentMapType = _currentMapType == MapType.normal 
                        ? MapType.satellite 
                        : _currentMapType == MapType.satellite 
                            ? MapType.hybrid 
                            : MapType.normal;
                  });
                },
                backgroundColor: Colors.white,
                elevation: 4,
                heroTag: "map_type_routes",
                child: Icon(
                  _currentMapType == MapType.normal 
                      ? Icons.satellite_alt 
                      : _currentMapType == MapType.satellite 
                          ? Icons.layers 
                          : Icons.map,
                  color: Colors.grey[700],
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _currentMapType == MapType.normal 
                      ? 'Normal' 
                      : _currentMapType == MapType.satellite 
                          ? 'Satellite' 
                          : 'Hybrid',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
