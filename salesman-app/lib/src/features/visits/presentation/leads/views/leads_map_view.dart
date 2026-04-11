// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/leads_card.dart';
import 'dart:ui' as ui;

import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/edit_a_lead_details_cubit.dart';
import 'package:track/src/features/visits/presentation/visit_log/cubit/visit_log_cubit.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class LeadsMapWidget extends StatefulWidget {
  final List<LeadsDetailsEntity> leads;

  const LeadsMapWidget({super.key, required this.leads});

  @override
  State<LeadsMapWidget> createState() => _LeadsMapWidgetState();
}

class _LeadsMapWidgetState extends State<LeadsMapWidget> {
  GoogleMapController? _controller;
  Set<Marker> _markers = {};
  LeadsDetailsEntity? _selectedLead;
  bool _isMapReady = false;
  bool _isCreatingMarkers = false;
  MapType _currentMapType = MapType.normal;

  // Filter state
  String _selectedStatus = 'All';
  List<String> _availableStatuses = ['All'];

  final Map<String, BitmapDescriptor> _markerIconCache = {};

  late LeadStatusCubit leadStatusCubit = context.read<LeadStatusCubit>();
  
  // Local copy of leads for real-time updates
  late List<LeadsDetailsEntity> _localLeads;

  @override
  void initState() {
    super.initState();
    _localLeads = List.from(widget.leads);
    _initializeStatuses();
    _initializeMapData();
  }

  @override
  void didUpdateWidget(LeadsMapWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.leads != widget.leads) {
      _localLeads = List.from(widget.leads);
      _initializeStatuses();
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

  void _initializeStatuses() {
    final statuses = _localLeads.map((lead) => lead.status).toSet().toList();
    statuses.sort();
    setState(() {
      _availableStatuses = ['All', ...statuses];
    });
  }

  void _updateLeadStatus(int leadID, String newStatus) {
    setState(() {
      final index = _localLeads.indexWhere((lead) => lead.leadID == leadID);
      if (index != -1) {
        final updatedLead = LeadsDetailsEntity(
          leadID: _localLeads[index].leadID,
          addressId: _localLeads[index].addressId,
          leadName: _localLeads[index].leadName,
          contactName: _localLeads[index].contactName,
          contactPhone: _localLeads[index].contactPhone,
          contactEmail: _localLeads[index].contactEmail,
          status: newStatus,
          leadAddress: _localLeads[index].leadAddress,
          pendingAssignment: _localLeads[index].pendingAssignment,
        );
        _localLeads[index] = updatedLead;
        
        // Update selected lead if it's the same one
        if (_selectedLead?.leadID == leadID) {
          _selectedLead = updatedLead;
        }
      }
    });
    
    // Refresh statuses and markers
    _initializeStatuses();
    _initializeMapData();
  }

  List<LeadsDetailsEntity> get _filteredLeads {
    if (_selectedStatus == 'All') {
      return _localLeads;
    }
    return _localLeads
        .where((lead) => lead.status == _selectedStatus)
        .toList();
  }

  Future<void> _initializeMapData() async {
    if (_isCreatingMarkers) return;

    setState(() {
      _isCreatingMarkers = true;
    });

    try {
      await _createMarkers();
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

  Future<BitmapDescriptor> _createPointedMarker(
    String status,
    Color markerColor,
  ) async {
    final cacheKey = '${status}_${markerColor.value}_${kIsWeb ? 'web' : 'mobile'}';

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
    final filteredLeads = _filteredLeads;
    if (filteredLeads.isEmpty) return;

    final List<Marker> markers = [];

    final validLeads = filteredLeads.asMap().entries.where((entry) {
      final lead = entry.value;
      return lead.leadAddress.latitude >= -90 &&
          lead.leadAddress.latitude <= 90 &&
          lead.leadAddress.longitude >= -180 &&
          lead.leadAddress.longitude <= 180;
    }).toList();

    if (validLeads.isEmpty) {
      if (mounted) {
        setState(() {
          _markers = <Marker>{};
        });
      }
      return;
    }

    for (final entry in validLeads) {
      final originalIndex = entry.key;
      final lead = entry.value;

      try {
        final markerColor = Color(
          int.parse(
            leadStatusCubit
                .getColorByLeadStatus(lead.status)
                .replaceFirst('#', '0xff'),
          ),
        );

        final markerIcon = await _createPointedMarker(
          lead.status,
          markerColor,
        );
        final position = LatLng(
          lead.leadAddress.latitude,
          lead.leadAddress.longitude,
        );

        markers.add(
          Marker(
            markerId: MarkerId('lead_$originalIndex'),
            position: position,
            infoWindow: InfoWindow(
              title: lead.leadAddress.streetAddress,
              snippet: 'Tap for details',
            ),
            onTap: () {
              if (mounted) {
                setState(() {
                  _selectedLead = lead;
                });
              }
            },
            icon: markerIcon,
            anchor: const Offset(0.5, 1.0),
          ),
        );
      } catch (e) {
        debugPrint('Error creating marker for lead $originalIndex: $e');
      }
    }

    if (mounted) {
      setState(() {
        _markers = markers.toSet();
      });
    }
  }

  LatLngBounds? _getBounds() {
    final filteredLeads = _filteredLeads;
    final validLeads = filteredLeads
        .where(
          (lead) =>
              lead.leadAddress.latitude >= -90 &&
              lead.leadAddress.latitude <= 90 &&
              lead.leadAddress.longitude >= -180 &&
              lead.leadAddress.longitude <= 180,
        )
        .toList();

    if (validLeads.isEmpty) {
      return null;
    }

    if (validLeads.length == 1) {
      final lead = validLeads.first;
      const double padding = 0.01;
      return LatLngBounds(
        southwest: LatLng(
          lead.leadAddress.latitude - padding,
          lead.leadAddress.longitude - padding,
        ),
        northeast: LatLng(
          lead.leadAddress.latitude + padding,
          lead.leadAddress.longitude + padding,
        ),
      );
    }

    double minLat = validLeads.first.leadAddress.latitude;
    double maxLat = validLeads.first.leadAddress.latitude;
    double minLng = validLeads.first.leadAddress.longitude;
    double maxLng = validLeads.first.leadAddress.longitude;

    for (final lead in validLeads) {
      minLat = minLat < lead.leadAddress.latitude
          ? minLat
          : lead.leadAddress.latitude;
      maxLat = maxLat > lead.leadAddress.latitude
          ? maxLat
          : lead.leadAddress.latitude;
      minLng = minLng < lead.leadAddress.longitude
          ? minLng
          : lead.leadAddress.longitude;
      maxLng = maxLng > lead.leadAddress.longitude
          ? maxLng
          : lead.leadAddress.longitude;
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
      final filteredLeads = _filteredLeads;
      if (filteredLeads.isNotEmpty) {
        final firstLead = filteredLeads.first;
        await _controller!.animateCamera(
          CameraUpdate.newLatLngZoom(
            LatLng(
              firstLead.leadAddress.latitude,
              firstLead.leadAddress.longitude,
            ),
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

  void _onStatusChanged(String? newStatus) {
    if (newStatus != null && newStatus != _selectedStatus) {
      setState(() {
        _selectedStatus = newStatus;
        _selectedLead = null; // Clear selected lead when filter changes
      });
      _initializeMapData(); // Refresh map with new filter
    }
  }


  Widget _buildStatusFilter() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedStatus,
            icon: const Icon(Icons.keyboard_arrow_down, color: Colors.grey),
            iconSize: 20,
            style: const TextStyle(
              color: Colors.black87,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
            onChanged: _onStatusChanged,
            items: _availableStatuses.map<DropdownMenuItem<String>>((
              String status,
            ) {
              return DropdownMenuItem<String>(
                value: status,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (status != 'All') ...[
                      Container(
                        width: 12,
                        height: 12,
                        margin: const EdgeInsets.only(right: 8),
                        decoration: BoxDecoration(
                          color: Color(
                            int.parse(
                              leadStatusCubit
                                  .getColorByLeadStatus(status)
                                  .replaceFirst('#', '0xff'),
                            ),
                          ),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ] else ...[
                      const Icon(
                        Icons.filter_list,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 8),
                    ],
                    Text(
                      status,
                      style: TextStyle(
                        color: _selectedStatus == status
                            ? Colors.black87
                            : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_localLeads.isEmpty) {
      return MyScaffold(
        title: "Leads Map View",
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.map, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'No leads available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final filteredLeads = _filteredLeads;
    LeadsDetailsEntity? firstValidLead;

    for (final lead in filteredLeads) {
      if (lead.leadAddress.latitude >= -90 &&
          lead.leadAddress.latitude <= 90 &&
          lead.leadAddress.longitude >= -180 &&
          lead.leadAddress.longitude <= 180) {
        firstValidLead = lead;
        break;
      }
    }

    firstValidLead ??= filteredLeads.isNotEmpty
        ? filteredLeads.first
        : _localLeads.first;

    return MultiBlocListener(
      listeners: [
        BlocListener<LeadsDetailsCubit, LeadsDetailsState>(
          listener: (context, state) {
            if (state is LeadsDetailsFailed) {
              context.errorBar(state.errorMessage);
            }
            if (state is LeadsDetailsLoaded) {
              final leadsDetailsCubit = context.read<LeadsDetailsCubit>();
              context.pushReplacement(
                Routes.leadsMapView,
                extra: leadsDetailsCubit.leadsData.allLeads,
              );
            }
          },
        ),
        BlocListener<EditALeadDetailsCubit, EditALeadDetailsState>(
          listener: (context, state) {
            if (state is EditALeadDetailsSuccess) {
              // Update local lead status immediately
              _updateLeadStatus(state.leadDetails.leadID, state.leadDetails.status);
            }
          },
        ),
        BlocListener<VisitLogCubit, VisitLogState>(
          listener: (context, state) {
            if (state is VisitLogSuccess) {
              // Update local lead status immediately after visit log
              _updateLeadStatus(state.leadID, state.leadStatus);
            }
          },
        ),
      ],
      child: MyScaffold(
        title: "Leads Map View",
        floatingActionButton: BlocBuilder<LeadsDetailsCubit, LeadsDetailsState>(
          builder: (context, state) {
            return FloatingActionButton.extended(
              onPressed: () async {
                final leadsDetailsCubit = context.read<LeadsDetailsCubit>();
                leadsDetailsCubit.loadMoreLeads();
              },
              label: state is LeadsDetailsLoading
                  ? Text("Loading")
                  : Text("Load more"),
              icon: state is LeadsDetailsLoading
                  ? SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        color: AppColors.white,
                        strokeWidth: 2,
                      ),
                    ).pRight(16)
                  : Icon(Icons.more).pRight(16),
            );
          },
        ),
        body: Stack(
          children: [
            GoogleMap(
              onMapCreated: _onMapCreated,
              initialCameraPosition: CameraPosition(
                target: LatLng(
                  firstValidLead.leadAddress.latitude,
                  firstValidLead.leadAddress.longitude,
                ),
                zoom: 15,
              ),
              minMaxZoomPreference: const MinMaxZoomPreference(3.0, 21.0),
              mapType: _currentMapType,
              markers: _markers,
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

            // Status Filter Dropdown
            Positioned(top: 0, left: 0, right: 0, child: _buildStatusFilter()),

            if (_isCreatingMarkers)
              Container(
                color: Colors.black26,
                child: const Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  ),
                ),
              ),

            if (_selectedLead != null)
              Positioned(
                top: 80, // Adjusted to account for the filter dropdown
                left: 16,
                right: 16,
                child: LeadsCard(
                  lead: _selectedLead!,
                  showExtraButtons: true,
                  onClose: () {
                    _selectedLead = null;
                    setState(() {});
                  },
                ),
              ),

            Positioned(
              bottom: 180,
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
                ],
              ),
            ),

            Positioned(
              bottom: 116,
              left: 16,
              child: FloatingActionButton(
                mini: true,
                onPressed: _fitBounds,
                backgroundColor: Colors.white,
                elevation: 4,
                heroTag: "fit_bounds",
                child: Icon(Icons.center_focus_strong, color: Colors.grey[700]),
              ),
            ),

            // Map type toggle buttons
            Positioned(
              bottom: 180,
              right: 16,
              child: Column(
                children: [
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
                    heroTag: "map_type",
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

            // Filter result counter
            if (filteredLeads.length != _localLeads.length)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Showing ${filteredLeads.length} of ${_localLeads.length} leads',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
