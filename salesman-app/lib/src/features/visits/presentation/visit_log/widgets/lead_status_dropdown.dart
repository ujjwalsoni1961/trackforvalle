import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/ui/widgets/center_error_widget.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/domain/entities/lead_status_entity.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';

class LeadStatusDropdown extends StatelessWidget {
  final LeadStatusEntity? selectedStatus;
  final Function(LeadStatusEntity?) onStatusChanged;
  final bool isContractSigned;

  const LeadStatusDropdown({
    super.key,
    required this.selectedStatus,
    required this.onStatusChanged,
    required this.isContractSigned,
  });

  LeadStatusEntity? getSignedStatus(List<LeadStatusEntity> statusList) {
    for (final status in statusList) {
      if (status.status == 'Signed') {
        return status;
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<LeadStatusCubit, LeadStatusState>(
      builder: (context, state) {
        if (state is LeadStatusFailed) {
          return const CenterErrorWidget(error: "Couldn't Fetch Status");
        }

        if (state is LeadStatusLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            child: Text("Loading status options..."),
          );
        }

        if (state is LeadStatusSuccess) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Status",
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const GapV(12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isContractSigned
                      ? Colors.grey.shade100
                      : selectedStatus != null
                      ? Color(
                          int.parse(
                            '0xFF${selectedStatus!.hexColor.replaceAll("#", "")}',
                          ),
                        ).withOpacity(0.15)
                      : Colors.grey.shade50,
                  border: Border.all(
                    color: isContractSigned
                        ? Colors.grey.shade200
                        : Colors.grey.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<LeadStatusEntity>(
                    value: isContractSigned
                        ? getSignedStatus(state.statusList)
                        : selectedStatus,
                    hint: Text(
                      "Select status...",
                      style: TextStyle(
                        color: isContractSigned
                            ? Colors.grey.shade300
                            : Colors.grey.shade400,
                      ),
                    ),
                    isExpanded: true,
                    onChanged: isContractSigned ? null : onStatusChanged,
                    items: state.statusList.map((status) {
                      final statusColor = Color(
                        int.parse('0xFF${status.hexColor.replaceAll("#", "")}'),
                      );

                      return DropdownMenuItem<LeadStatusEntity>(
                        value: status,
                        enabled: !isContractSigned,
                        child: Row(
                          children: [
                            Container(
                              width: 16,
                              height: 16,
                              margin: const EdgeInsets.only(right: 12),
                              decoration: BoxDecoration(
                                color: statusColor,
                                shape: BoxShape.circle,
                              ),
                            ),
                            Text(
                              status.status,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isContractSigned
                                    ? Colors.black87
                                    : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const GapV(24),
            ],
          );
        }

        return const SizedBox();
      },
    );
  }
}
