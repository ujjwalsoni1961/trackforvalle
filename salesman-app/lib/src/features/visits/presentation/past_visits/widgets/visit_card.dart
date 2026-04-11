// ignore_for_file: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/views/past_visit_details_view.dart';

class PastVisitCard extends StatefulWidget {
  final PastVisitItemEntity visit;
  const PastVisitCard({required this.visit, super.key});

  @override
  State<PastVisitCard> createState() => _PastVisitCardState();
}

class _PastVisitCardState extends State<PastVisitCard> {
  late ThemeData theme = Theme.of(context);

  @override
  Widget build(BuildContext context) {
    final visit = widget.visit;
    final lead = visit.lead;
    final leadStatusCubit = context.read<LeadStatusCubit>();
    final String colorString = leadStatusCubit
        .getColorByLeadStatus(lead.status)
        .replaceFirst('#', '');
    final Color statusChipColor = Color(int.parse('0xff$colorString'));

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => PastVisitDetailsScreen(visit: visit),
          ),
        );
      },
      child: Card(
        elevation: 3,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.secondary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 26,
                backgroundColor: theme.colorScheme.secondary.withOpacity(0.1),
                child: Icon(
                  Icons.event_available,
                  color: theme.colorScheme.secondary,
                  size: 28,
                ),
              ),
            ),
            const GapH(16),
            // Main Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Lead Name
                  Text(
                    lead.leadName,
                    style: theme.textTheme.bodyLarge!.copyWith(
                      color: theme.colorScheme.secondary,
                      fontWeight: FontWeight.w600,
                      fontSize: 17,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const GapV(6),
                  // Check-In Time
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 14,
                        color: AppColors.greyDark.withOpacity(0.7),
                      ),
                      const GapH(4),
                      Expanded(
                        child: Text(
                          DateFormat(
                            'MMM dd, yyyy - hh:mm a',
                          ).format(visit.checkInTime),
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.greyDark.withOpacity(0.9),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const GapV(10),
                  // Lead Status Chip
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 5,
                      ),
                      decoration: BoxDecoration(
                        color: statusChipColor,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: statusChipColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.circle, size: 8, color: Colors.white),
                          const GapH(4),
                          Text(
                            lead.status,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Trailing Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: theme.colorScheme.secondary,
              ),
            ),
          ],
        ).pAll(18),
      ),
    );
  }
}
