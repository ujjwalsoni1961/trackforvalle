// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/domain/entities/daily_routes_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/views/each_leads_details_view.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/common_routes_and_leads.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/leads_action_buttons.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/choose_contract_view.dart';
import 'package:url_launcher/url_launcher.dart';

// Modified RouteCard widget to wrap ETA and distance row

class RouteCard extends StatefulWidget {
  final DailyRoutesEntity route;
  final VoidCallback? onClose;
  final bool showExtraButtons;
  final bool? isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final VoidCallback? onTap;
  final VoidCallback? onNavigate;
  final VoidCallback? onLogVisit;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewDetails;
  final int? index;

  const RouteCard({
    super.key,
    required this.route,
    this.onClose,
    this.showExtraButtons = true,
    this.isSelected,
    this.onSelectionChanged,
    this.onTap,
    this.onNavigate,
    this.onLogVisit,
    this.onViewHistory,
    this.onViewDetails,
    this.index,
  });

  @override
  State<RouteCard> createState() => _RouteCardState();
}

class _RouteCardState extends State<RouteCard>
    with SingleTickerProviderStateMixin {
  late ThemeData theme = Theme.of(context);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late LeadStatusCubit leadStatusCubit = context.read<LeadStatusCubit>();
  bool isExpanded = false;

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) {
      hex = 'FF$hex';
    }
    return Color(int.parse(hex, radix: 16));
  }

  Color getColorByStatus(String status) {
    String hex = leadStatusCubit.getColorByLeadStatus(status);
    return hexToColor(hex);
  }

  void toggleExpanded() {
    setState(() {
      isExpanded = !isExpanded;
    });
  }

  @override
  void initState() {
    super.initState();
    isExpanded = widget.showExtraButtons;
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation = Tween<double>(begin: -20.0, end: 0.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final route = widget.route;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: toggleExpanded,
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: theme.colorScheme.primary.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                      spreadRadius: 0,
                    ),
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ],
                  border: Border.all(
                    color: theme.colorScheme.primary.withOpacity(0.08),
                    width: 1,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            if (widget.index != null)
                              Container(
                                margin: const EdgeInsets.only(right: 8),
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  '${widget.index! + 1}',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            if (widget.onSelectionChanged != null)
                              Container(
                                margin: const EdgeInsets.only(right: 12),
                                child: Transform.scale(
                                  scale: 1.0,
                                  child: Checkbox(
                                    value: widget.isSelected ?? false,
                                    onChanged: (bool? value) {
                                      widget.onSelectionChanged!(
                                        value ?? false,
                                      );
                                    },
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    activeColor: theme.colorScheme.primary,
                                    checkColor: Colors.white,
                                  ),
                                ),
                              ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    theme.colorScheme.primary.withOpacity(0.1),
                                    theme.colorScheme.primary.withOpacity(0.05),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.15,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                Icons.route_outlined,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const GapH(12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    route.address,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 14,
                                          color: theme.colorScheme.onSurface,
                                          letterSpacing: -0.2,
                                        ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const GapV(4),
                                  if (route.name.isNotEmpty &&
                                      route.name != "anonymous")
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.blue.withOpacity(0.1),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.person,
                                            size: 12,
                                            color: Colors.blue.withOpacity(0.8),
                                          ),
                                        ),
                                        const GapH(6),
                                        Expanded(
                                          child: Text(
                                            route.name,
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey
                                                      .withOpacity(0.8),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  if (route.eta.isNotEmpty ||
                                      route.distance > 0)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Wrap(
                                        // Changed Row to Wrap
                                        spacing: 12,
                                        runSpacing: 4,
                                        children: [
                                          if (route.eta.isNotEmpty) ...[
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.orange
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.access_time,
                                                    size: 12,
                                                    color: Colors.orange
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                                const GapH(4),
                                                Text(
                                                  route.eta,
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.grey
                                                            .withOpacity(0.8),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                          if (route.distance > 0) ...[
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Container(
                                                  padding: const EdgeInsets.all(
                                                    3,
                                                  ),
                                                  decoration: BoxDecoration(
                                                    color: Colors.green
                                                        .withOpacity(0.1),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                          4,
                                                        ),
                                                  ),
                                                  child: Icon(
                                                    Icons.social_distance,
                                                    size: 12,
                                                    color: Colors.green
                                                        .withOpacity(0.8),
                                                  ),
                                                ),
                                                const GapH(4),
                                                Text(
                                                  '${route.distance.toStringAsFixed(1)} km',
                                                  style: theme
                                                      .textTheme
                                                      .bodyMedium
                                                      ?.copyWith(
                                                        color: Colors.grey
                                                            .withOpacity(0.8),
                                                        fontSize: 12,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            StatusChip(
                              status: route.leadStatus,
                              accentColor: getColorByStatus(route.leadStatus),
                            ),
                            const GapH(8),
                            if (widget.onClose != null)
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: GestureDetector(
                                  onTap: widget.onClose,
                                  child: Icon(
                                    Icons.close,
                                    size: 12,
                                    color: Colors.red.withOpacity(0.8),
                                  ),
                                ),
                              )
                            else
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withOpacity(
                                    0.1,
                                  ),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Icon(
                                  Icons.arrow_forward_ios,
                                  size: 12,
                                  color: theme.colorScheme.primary,
                                ),
                              ),
                          ],
                        ),
                        if (isExpanded) ...[
                          const GapV(12),
                          RouteActionButtons(
                            route: route,
                            onNavigate: widget.onNavigate,
                            onLogVisit: widget.onLogVisit,
                            onViewHistory: widget.onViewHistory,
                            onViewDetails: widget.onViewDetails,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class RouteActionButtons extends StatelessWidget {
  final DailyRoutesEntity route;
  final VoidCallback? onNavigate;
  final VoidCallback? onLogVisit;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewDetails;

  const RouteActionButtons({
    super.key,
    required this.route,
    this.onNavigate,
    this.onLogVisit,
    this.onViewHistory,
    this.onViewDetails,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Primary Actions Row
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.navigation,
                label: 'Navigate',
                onPressed:
                    onNavigate ?? () => _handleNavigation(context, route),
                isPrimary: true,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
            const GapH(8),
            Expanded(
              child: ActionButton(
                icon: Icons.assignment_turned_in,
                label: 'Log Visit',
                onPressed: onLogVisit ?? () => _handleLogVisit(context, route),
                backgroundColor: Colors.grey.withOpacity(0.1),
                foregroundColor: Colors.grey.withOpacity(0.9),
                borderColor: Colors.grey.withOpacity(0.5),
              ),
            ),
          ],
        ),

        // Secondary Actions Row
        const GapV(8),
        Row(
          children: [
            Expanded(
              child: ActionButton(
                icon: Icons.history,
                label: 'Visit History',
                onPressed:
                    onViewHistory ?? () => _handleVisitHistory(context, route),
                backgroundColor: Colors.blue.withOpacity(0.1),
                foregroundColor: Colors.blue.withOpacity(0.9),
                borderColor: Colors.blue.withOpacity(0.5),
              ),
            ),
            const GapH(8),
            Expanded(
              child: ActionButton(
                icon: Icons.info_outline,
                label: 'View Details',
                onPressed:
                    onViewDetails ?? () => _handleViewDetails(context, route),
                backgroundColor: Colors.green.withOpacity(0.1),
                foregroundColor: Colors.green.withOpacity(0.9),
                borderColor: Colors.green.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, DailyRoutesEntity route) async {
    final lat = route.latitude;
    final lng = route.longitude;

    final googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$lat,$lng&destination_place_id=&travelmode=driving';
    final appleMapsUrl = 'https://maps.apple.com/?daddr=$lat,$lng';

    try {
      if (await canLaunchUrl(Uri.parse(googleMapsUrl))) {
        await launchUrl(
          Uri.parse(googleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else if (await canLaunchUrl(Uri.parse(appleMapsUrl))) {
        await launchUrl(
          Uri.parse(appleMapsUrl),
          mode: LaunchMode.externalApplication,
        );
      } else {
        final browserUrl =
            'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
        await launchUrl(
          Uri.parse(browserUrl),
          mode: LaunchMode.externalApplication,
        );
      }

      if (context.mounted) {
        context.successBar("Opening Maps...");
      }
    } catch (e) {
      if (context.mounted) {
        context.errorBar("Couldn't Open Maps");
      }
    }
  }

  void _handleLogVisit(BuildContext context, DailyRoutesEntity route) {
    context.push(
      Routes.visitLogView,
      extra: LeadIDVisitIDPageParams(
        leadId: route.leadID,
        visitId: route.visitID,
        currentLeadStatus: route.leadStatus,
      ),
    );
  }

  void _handleVisitHistory(BuildContext context, DailyRoutesEntity route) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PastVisitHistoryLeadIDFilteredPage(leadID: route.leadID),
      ),
    );
  }

  void _handleViewDetails(BuildContext context, DailyRoutesEntity route) {
    debugPrint('Viewing details for lead ${route}');
    for (final l in context.read<LeadsDetailsCubit>().leadsData.allLeads) {
      if (l.leadID == route.leadID) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EachLeadsDetailsPage(lead: l),
          ),
        );
        break;
      }
    }
  }
}
