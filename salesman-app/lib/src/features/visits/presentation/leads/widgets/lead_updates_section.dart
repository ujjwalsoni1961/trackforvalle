import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/lead_id_past_visits_cubit.dart';

class LeadUpdatesSection extends StatefulWidget {
  final LeadsDetailsEntity lead;
  final int maxUpdates;

  const LeadUpdatesSection({
    super.key,
    required this.lead,
    this.maxUpdates = 3,
  });

  @override
  State<LeadUpdatesSection> createState() => _LeadUpdatesSectionState();
}

class _LeadUpdatesSectionState extends State<LeadUpdatesSection> {
  late LeadIdPastVisitsCubit _pastVisitsCubit;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _pastVisitsCubit = context.read<LeadIdPastVisitsCubit>();
    _loadRecentUpdates();
  }

  void _loadRecentUpdates() {
    if (!_isInitialized) {
      _pastVisitsCubit.getLeadPastVisits(
        leadID: widget.lead.leadID,
        pageNumber: 1,
        limit: widget.maxUpdates,
      );
      _isInitialized = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocBuilder<LeadIdPastVisitsCubit, LeadIdPastVisitsState>(
      builder: (context, state) {
        if (state is LeadIDPastVisitsLoading && state.isFirstPage) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const GapH(8),
                Text(
                  'Loading updates...',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                  ),
                ),
              ],
            ),
          );
        }

        if (state is LeadIDPastVisitsFailed) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.error_outline,
                  size: 16,
                  color: Colors.red,
                ),
                const GapH(8),
                Expanded(
                  child: Text(
                    'Failed to load updates',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        final visits = _pastVisitsCubit.leadIDPastVisits.visits;
        final recentVisitsWithNotes = visits
            .where((visit) => visit.notes.trim().isNotEmpty)
            .take(widget.maxUpdates)
            .toList();

        if (recentVisitsWithNotes.isEmpty) {
          return Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface.withOpacity(0.3),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: theme.colorScheme.outline.withOpacity(0.2),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
                const GapH(8),
                Text(
                  'No recent updates available',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(
                  Icons.update,
                  size: 16,
                  color: theme.colorScheme.primary,
                ),
                const GapH(6),
                Text(
                  'Recent Updates',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const Spacer(),
                if (visits.length > widget.maxUpdates)
                  Text(
                    '${recentVisitsWithNotes.length} of ${visits.length}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withOpacity(0.6),
                      fontSize: 11,
                    ),
                  ),
              ],
            ),
            const GapV(8),
            
            // Updates List
            ...recentVisitsWithNotes.map((visit) => _buildUpdateItem(visit, theme)),
          ],
        );
      },
    );
  }

  Widget _buildUpdateItem(PastVisitItemEntity visit, ThemeData theme) {
    final dateFormat = DateFormat('MMM dd, yyyy');
    final timeFormat = DateFormat('hh:mm a');
    
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with date and status
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  visit.status ?? 'Visit',
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                '${dateFormat.format(visit.checkInTime)} • ${timeFormat.format(visit.checkInTime)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: 10,
                  color: theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ),
          const GapV(6),
          
          // Notes content
          Text(
            visit.notes.trim(),
            style: theme.textTheme.bodySmall?.copyWith(
              fontSize: 12,
              color: theme.colorScheme.onSurface,
              height: 1.3,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}