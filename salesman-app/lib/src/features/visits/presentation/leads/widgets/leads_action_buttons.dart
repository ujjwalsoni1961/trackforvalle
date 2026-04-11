// Lead Action Buttons Widget
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/presentation/leads/views/each_leads_details_view.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/common_routes_and_leads.dart';
import 'package:track/src/features/visits/presentation/past_visits/views/leadid_past_visit_history.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/choose_contract_view.dart';
import 'package:url_launcher/url_launcher.dart';

const Color _kLogVisitColor = Colors.grey;
const Color _kHistoryColor = Colors.blue;
const Color _kDetailsColor = Colors.green;

class LeadActionButtons extends StatelessWidget {
  final LeadsDetailsEntity lead;
  final VoidCallback? onNavigate;
  final VoidCallback? onLogVisit;
  final VoidCallback? onViewHistory;
  final VoidCallback? onViewDetails;

  const LeadActionButtons({
    super.key,
    required this.lead,
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
                onPressed: onNavigate ?? () => _handleNavigation(context, lead),
                isPrimary: true,
                backgroundColor: theme.colorScheme.primary,
              ),
            ),
            const GapH(8),
            Expanded(
              child: ActionButton(
                icon: Icons.assignment_turned_in,
                label: 'Log Visit',
                onPressed: onLogVisit ?? () => _handleLogVisit(context, lead),
                backgroundColor: _kLogVisitColor.withOpacity(0.1),
                foregroundColor: _kLogVisitColor.withOpacity(0.9),
                borderColor: _kLogVisitColor.withOpacity(0.5),
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
                    onViewHistory ?? () => _handleVisitHistory(context, lead),
                backgroundColor: _kHistoryColor.withOpacity(0.1),
                foregroundColor: _kHistoryColor.withOpacity(0.9),
                borderColor: _kHistoryColor.withOpacity(0.5),
              ),
            ),
            const GapH(8),
            Expanded(
              child: ActionButton(
                icon: Icons.info_outline,
                label: 'View Details',
                onPressed:
                    onViewDetails ?? () => _handleViewDetails(context, lead),
                backgroundColor: _kDetailsColor.withOpacity(0.1),
                foregroundColor: _kDetailsColor.withOpacity(0.9),
                borderColor: _kDetailsColor.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _handleNavigation(BuildContext context, LeadsDetailsEntity lead) async {
    final lat = lead.leadAddress.latitude;
    final lng = lead.leadAddress.longitude;

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

  void _handleLogVisit(BuildContext context, LeadsDetailsEntity lead) {
    context.push(
      Routes.visitLogView,
      extra: LeadIDVisitIDPageParams(
        leadId: lead.leadID,
        visitId: -1,
        currentLeadStatus: lead.status,
      ),
    );
  }

  void _handleVisitHistory(BuildContext context, LeadsDetailsEntity lead) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            PastVisitHistoryLeadIDFilteredPage(leadID: lead.leadID),
      ),
    );
  }

  void _handleViewDetails(BuildContext context, LeadsDetailsEntity lead) {
    debugPrint('Viewing details for lead ${lead.leadID}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => EachLeadsDetailsPage(lead: lead)),
    );
  }
}

class PastVisitHistoryLeadIDFilteredPage extends StatefulWidget {
  final int leadID;
  const PastVisitHistoryLeadIDFilteredPage({super.key, required this.leadID});

  @override
  State<PastVisitHistoryLeadIDFilteredPage> createState() =>
      _PastVisitHistoryLeadIDFilteredPageState();
}

class _PastVisitHistoryLeadIDFilteredPageState
    extends State<PastVisitHistoryLeadIDFilteredPage> {
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Visit History',
      body: LeadIDPastVisitsHistoryView(leadID: widget.leadID),
    );
  }
}
