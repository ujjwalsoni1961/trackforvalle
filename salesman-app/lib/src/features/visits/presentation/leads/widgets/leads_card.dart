// Main LeadsCard Widget
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/views/each_leads_details_view.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/leads_action_buttons.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/common_routes_and_leads.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/lead_updates_section.dart';

class LeadsCard extends StatefulWidget {
  final LeadsDetailsEntity lead;
  final bool? isSelected;
  final ValueChanged<bool>? onSelectionChanged;
  final bool showExtraButtons;
  final VoidCallback? onTap;
  final VoidCallback? onNavigate;
  final VoidCallback? onLogVisit;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewDetails;
  final VoidCallback? onClose;
  final String? status;
  final String? time; // Added optional time parameter

  const LeadsCard({
    super.key,
    required this.lead,
    this.isSelected,
    this.onSelectionChanged,
    this.showExtraButtons = false,
    this.onTap,
    this.onNavigate,
    this.onLogVisit,
    this.onViewHistory,
    this.onViewDetails,
    this.onClose,
    this.time, // Added to constructor
    this.status,
  });

  @override
  State<LeadsCard> createState() => _LeadsCardState();
}

class _LeadsCardState extends State<LeadsCard>
    with SingleTickerProviderStateMixin {
  late ThemeData theme = Theme.of(context);
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  late LeadStatusCubit leadStatusCubit = context.read<LeadStatusCubit>();

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

  @override
  void initState() {
    super.initState();
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

  void _handleDefaultTap() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EachLeadsDetailsPage(lead: widget.lead),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final lead = widget.lead;
    final address = lead.leadAddress;

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: GestureDetector(
              onTap: widget.onTap ?? _handleDefaultTap,
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
                        // Header Section
                        Row(
                          children: [
                            // Selection Checkbox
                            if (widget.onSelectionChanged != null)
                              Transform.scale(
                                scale: 1.0,
                                child: Checkbox(
                                  value: widget.isSelected ?? false,
                                  onChanged: (bool? value) {
                                    widget.onSelectionChanged!(value ?? false);
                                  },
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  activeColor: theme.colorScheme.primary,
                                  checkColor: Colors.white,
                                ),
                              ),

                            // Avatar with sleek design
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
                                Icons.person_outline,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                            const GapH(12),
                            // Main Info Section
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Street Address as Title
                                  Text(
                                    lead.leadAddress.streetAddress,
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
                                  // Location Info
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
                                          Icons.location_on,
                                          size: 12,
                                          color: Colors.blue.withOpacity(0.8),
                                        ),
                                      ),
                                      const GapH(6),
                                      Expanded(
                                        child: Text(
                                          '${address.postalCode}, ${address.city}, ${address.state}',
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                  // Comments snippet (if present)
                                  if (address.comments.trim().isNotEmpty) ...[
                                    const GapV(4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.amber.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.comment_outlined,
                                            size: 12,
                                            color: Colors.amber.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ),
                                        const GapH(6),
                                        Expanded(
                                          child: Text(
                                            address.comments.trim(),
                                            style: theme.textTheme.bodyMedium
                                                ?.copyWith(
                                                  color: Colors.grey.withOpacity(
                                                    0.8,
                                                  ),
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.w500,
                                                  fontStyle: FontStyle.italic,
                                                ),
                                            maxLines: 1,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  // Time Info (Optional)
                                  if (widget.time != null &&
                                      widget.time!.isNotEmpty) ...[
                                    const GapV(4),
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(3),
                                          decoration: BoxDecoration(
                                            color: Colors.orange.withOpacity(
                                              0.1,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              4,
                                            ),
                                          ),
                                          child: Icon(
                                            Icons.access_time,
                                            size: 12,
                                            color: Colors.orange.withOpacity(
                                              0.8,
                                            ),
                                          ),
                                        ),
                                        const GapH(4),
                                        Text(
                                          widget.time!,
                                          style: theme.textTheme.bodyMedium
                                              ?.copyWith(
                                                color: Colors.grey.withOpacity(
                                                  0.8,
                                                ),
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            // Status Badge
                            StatusChip(
                              status: widget.status ?? lead.status,
                              accentColor: getColorByStatus(
                                widget.status ?? lead.status,
                              ),
                            ),
                            const GapH(8),
                            // Close button or Trailing Arrow
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
                        // Action Buttons Section (only show if showExtraButtons is true)
                        if (widget.showExtraButtons) ...[
                          const GapV(12),
                          LeadActionButtons(
                            lead: lead,
                            onNavigate: widget.onNavigate,
                            onLogVisit: widget.onLogVisit,
                            onViewHistory: widget.onViewHistory,
                            onViewDetails: widget.onViewDetails,
                          ),
                          const GapV(12),
                          LeadUpdatesSection(lead: lead),
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
