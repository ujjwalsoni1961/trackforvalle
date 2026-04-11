// ignore_for_file: use_build_context_synchronously, deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/network/api.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/views/edit_a_lead_details_view.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/common_routes_and_leads.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/choose_contract_view.dart';
import 'package:track/src/features/visits/presentation/sign_contract/widgets/contract_preview.dart';
import 'package:url_launcher/url_launcher.dart';

class EachLeadsDetailsPage extends StatefulWidget {
  final LeadsDetailsEntity lead;

  const EachLeadsDetailsPage({required this.lead, super.key});

  @override
  State<EachLeadsDetailsPage> createState() => _EachLeadsDetailsPageState();
}

class _EachLeadsDetailsPageState extends State<EachLeadsDetailsPage> {
  late ThemeData theme;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    theme = Theme.of(context);
  }

  void _handleNavigation(double lat, double lng) async {
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
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final address = widget.lead.leadAddress;
    final bool isAlreadySigned = widget.lead.status.toLowerCase() == 'signed';

    return MyScaffold(
      appBar: AppBar(
        title: Text(widget.lead.leadName),
        actions: [
          TextButton.icon(
            onPressed: () {
              _handleNavigation(
                widget.lead.leadAddress.latitude,
                widget.lead.leadAddress.longitude,
              );
            },
            label: Text('Navigate'),
            icon: Icon(Icons.directions_outlined),
          ),
          const GapH(16),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditLeadsDetailsPage(lead: widget.lead),
            ),
          );
        },
        foregroundColor: AppColors.white,
        child: const Icon(Icons.edit_outlined),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sign Contract / View Contract Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: SizedBox(
                width: double.infinity,
                child: isAlreadySigned
                    ? OutlinedButton.icon(
                        onPressed: () => _viewSignedContract(context, widget.lead.leadID),
                        icon: Icon(
                          Icons.description,
                          size: 18,
                          color: Colors.green.shade700,
                        ),
                        label: Text(
                          "View Signed Contract",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.green.shade700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.green.shade700,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.green.shade50.withOpacity(0.05),
                        ),
                      )
                    : OutlinedButton.icon(
                        onPressed: () {
                          context.push(
                            RoutePaths.chooseContract,
                            extra: LeadIDVisitIDPageParams(
                              leadId: widget.lead.leadID,
                              visitId: -1,
                              currentLeadStatus: widget.lead.status,
                            ),
                          );
                        },
                        icon: Icon(
                          Icons.edit_document,
                          size: 18,
                          color: Colors.blue.shade700,
                        ),
                        label: Text(
                          "Sign Contract",
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                            color: Colors.blue.shade700,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(
                            color: Colors.blue.shade700,
                            width: 1.5,
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 14,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          backgroundColor: Colors.blue.shade50.withOpacity(0.05),
                        ).copyWith(
                          overlayColor: WidgetStateProperty.all(
                            Colors.blue.withOpacity(0.08),
                          ),
                        ),
                      ),
              ),
            ),
            // Details Section
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailCard(
                  icon: Icons.person,
                  title: 'Contact Name',
                  value: widget.lead.contactName,
                ),
                _buildDetailCard(
                  icon: Icons.phone,
                  title: 'Contact Phone',
                  value: widget.lead.contactPhone,
                ),
                _buildDetailCard(
                  icon: Icons.email,
                  title: 'Contact Email',
                  value: widget.lead.contactEmail,
                ),
                _buildDetailCard(
                  icon: Icons.info,
                  title: 'Status',
                  value: widget.lead.status,
                  isChip: true,
                ),
                _buildDetailCard(
                  icon: Icons.location_on,
                  title: 'Address',
                  value: [
                    address.streetAddress,
                    address.buildingUnit,
                    address.city,
                    address.state,
                    address.postalCode,
                    address.country,
                  ].where((part) => part.trim().isNotEmpty).join(', '),
                ),
                _buildDetailCard(
                  icon: Icons.landscape,
                  title: 'Landmark',
                  value: address.landmark,
                ),
                _buildDetailCard(
                  icon: Icons.map,
                  title: 'Coordinates',
                  value: '(${address.latitude}, ${address.longitude})',
                ),
              ],
            ).pBottom(24),
          ],
        ),
      ),
    );
  }

  void _viewSignedContract(BuildContext context, int leadId) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final api = sl<API>();
      final response = await api.dio.get('/contract/by-lead/$leadId');

      if (!context.mounted) return;
      Navigator.of(context).pop(); // dismiss loading

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'];
        final contractId = data['contract_id'] as int;
        final title = data['template_title'] as String? ?? 'Contract';

        // Open full-screen dialog with contract preview
        showDialog(
          context: context,
          builder: (ctx) => Dialog.fullscreen(
            child: Scaffold(
              appBar: AppBar(
                title: Text(title),
                leading: IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.of(ctx).pop(),
                ),
              ),
              body: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ContractPreview(
                  templateString: '',
                  contractId: contractId,
                ),
              ),
            ),
          ),
        );
      } else {
        context.errorBar(response.data['message'] ?? 'No contract found for this lead');
      }
    } catch (e) {
      if (context.mounted) {
        Navigator.of(context).pop(); // dismiss loading
        context.errorBar('Failed to load contract');
      }
      debugPrint('Error loading contract: $e');
    }
  }

  late LeadStatusCubit leadStatusCubit = context.read<LeadStatusCubit>();

  Color hexToColor(String hex) {
    hex = hex.replaceAll('#', '');

    if (hex.length == 6) {
      hex = 'FF$hex'; // Add 100% opacity if alpha not provided
    }

    return Color(int.parse(hex, radix: 16));
  }

  Color getColorByStatus(String status) {
    String hex = leadStatusCubit.getColorByLeadStatus(status);
    return hexToColor(hex);
  }

  Widget _buildDetailCard({
    required IconData icon,
    required String title,
    required String value,
    bool isChip = false,
  }) {
    return Card(
      margin: const EdgeInsets.only(top: 8, right: 16, left: 16, bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: theme.colorScheme.primary, size: 20),
          ),
          const GapH(16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.labelLarge),
                const GapV(4),
                isChip
                    ? StatusChip(
                        status: value,
                        accentColor: getColorByStatus(value),
                      )
                    : Text(
                        value.isEmpty ? "Not Updated" : value,
                        style: theme.textTheme.bodyLarge!.copyWith(
                          color: AppColors.black.withOpacity(0.8),
                        ),
                      ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: value));
              context.successBar(('$title copied to clipboard'));
            },
            icon: Icon(
              Icons.copy,
              color: theme.colorScheme.tertiary.withOpacity(0.8),
            ),
          ),
        ],
      ).pAll(16),
    );
  }
}
