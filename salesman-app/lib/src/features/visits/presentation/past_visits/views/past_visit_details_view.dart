import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/features/visits/domain/entities/past_visit_entity.dart';
import 'package:track/src/features/visits/presentation/leads/views/each_leads_details_view.dart';
import 'package:track/src/features/visits/presentation/past_visits/views/visits_contract_view_modal.dart';

class PastVisitDetailsScreen extends StatelessWidget {
  final PastVisitItemEntity visit;

  const PastVisitDetailsScreen({super.key, required this.visit});

  void _openContractModal(BuildContext context) {
    if (visit.contract != null) {
      showDialog(
        context: context,
        builder: (context) => ContractViewModal(
          templateString: visit.contract!.renderedHtml,
          leadName: visit.lead.leadName,
          contractID: visit.contract!.id,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          visit.lead.leadName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle('Visit Details'),
            _buildDetailCard([
              _buildDetailRow(
                'Date',
                DateFormat('MMM dd, yyyy').format(visit.checkInTime),
              ),
              _buildDetailRow(
                'Time',
                '${DateFormat('hh:mm a').format(visit.checkInTime)} - ${DateFormat('hh:mm a').format(visit.checkOutTime)}',
              ),
              _buildDetailRow(
                'Location',
                '${visit.latitude.toStringAsFixed(4)}, ${visit.longitude.toStringAsFixed(4)}',
              ),
              _buildDetailRow(
                'Notes',
                visit.notes.isNotEmpty ? visit.notes : 'No notes provided',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle('Lead Information'),
            _buildDetailCard([
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          EachLeadsDetailsPage(lead: visit.lead),
                    ),
                  );
                },
                child: _buildDetailRow(
                  'Contact Name',
                  visit.lead.contactName.isNotEmpty
                      ? visit.lead.contactName
                      : 'N/A',
                  isLink: true,
                ),
              ),
              _buildDetailRow(
                'Email',
                visit.lead.contactEmail.isNotEmpty
                    ? visit.lead.contactEmail
                    : 'N/A',
              ),
              _buildDetailRow(
                'Phone',
                visit.lead.contactPhone.isNotEmpty
                    ? visit.lead.contactPhone
                    : 'N/A',
              ),
              _buildDetailRow(
                'Status',
                visit.lead.status.isNotEmpty ? visit.lead.status : 'N/A',
              ),
            ]),
            const SizedBox(height: 16),
            _buildSectionTitle('Contract'),
            visit.contract != null
                ? _buildDetailCard([
                    GestureDetector(
                      onTap: () => _openContractModal(context),
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: Colors.blue.shade200,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.description,
                              color: Colors.blue.shade600,
                              size: 24,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Contract Available',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.blue.shade800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Tap to view contract details',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.blue.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Icon(
                              Icons.arrow_forward_ios,
                              color: Colors.blue.shade600,
                              size: 16,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ])
                : _buildDetailCard([
                    _buildDetailRow('Contract', 'No contract available'),
                  ]),
            const SizedBox(height: 16),
            _buildSectionTitle('Follow-Up Visits'),
            visit.followUpVisits != null && visit.followUpVisits!.isNotEmpty
                ? _buildDetailCard(
                    visit.followUpVisits!
                        .map(
                          (followUp) => _buildDetailRow(
                            followUp.followUp.subject.isNotEmpty
                                ? followUp.followUp.subject
                                : 'No subject',
                            DateFormat(
                              'MMM dd, yyyy',
                            ).format(followUp.followUp.scheduledDate),
                          ),
                        )
                        .toList(),
                  )
                : _buildDetailCard([
                    _buildDetailRow(
                      'Follow-Ups',
                      'No follow-up visits scheduled',
                    ),
                  ]),
            const SizedBox(height: 16),
          ],
        ).pSymmetric(horizontal: 16),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: Colors.black87,
        ),
      ),
    );
  }

  Widget _buildDetailCard(List<Widget> children) {
    return Card(
      elevation: 0,
      color: Colors.grey.shade50,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(children: children),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, {bool isLink = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.black54,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: isLink ? Colors.blue : Colors.black87,
                decoration: isLink ? TextDecoration.underline : null,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
