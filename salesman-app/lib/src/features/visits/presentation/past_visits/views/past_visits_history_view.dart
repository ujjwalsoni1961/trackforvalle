// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:track/src/core/ui/utility/center_loading_text_widget.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/center_error_widget.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/leads_card.dart';
import 'dart:async';
import 'package:track/src/features/visits/presentation/past_visits/cubit/past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/views/past_visit_details_view.dart';

class PastVisitsHistoryView extends StatefulWidget {
  const PastVisitsHistoryView({super.key});

  @override
  State<PastVisitsHistoryView> createState() => _PastVisitsHistoryViewState();
}

class _PastVisitsHistoryViewState extends State<PastVisitsHistoryView> {
  final ScrollController _scrollController = ScrollController();
  late final PastVisitsCubit pastVisitsCubit = context.read<PastVisitsCubit>();
  late ThemeData theme = Theme.of(context);
  int _currentPage = 1;
  Timer? _debounce;
  String? _selectedStatus;

  // Status options for the dropdown
  final List<String> _statusOptions = ["All"];

  @override
  void initState() {
    super.initState();
    _statusOptions.addAll(
      context
          .read<LeadStatusCubit>()
          .leadStatusList
          .map((e) => e.status)
          .toList(),
    );
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        _loadMoreVisits();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _loadMoreVisits() {
    if (pastVisitsCubit.state is PastVisitsLoading &&
        !(pastVisitsCubit.state as PastVisitsLoading).isFirstPage) {
      return;
    }
    if (_currentPage >= pastVisitsCubit.pastVisits.pagination.totalPages) {
      return;
    }
    _currentPage++;
    pastVisitsCubit.getGeneralPastVisits(
      pageNumber: _currentPage,
      leadStatus: _selectedStatus == 'All' ? null : _selectedStatus,
    );
  }

  void _onStatusChanged(String? status) {
    setState(() {
      _selectedStatus = status;
      _currentPage = 1;
    });
    pastVisitsCubit.getGeneralPastVisits(
      pageNumber: 1,
      leadStatus: status == 'All' ? null : status,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PastVisitsCubit, PastVisitsState>(
      builder: (context, state) {
        if (state is PastVisitsLoading && state.isFirstPage) {
          return const CenterLoadingTextWidget(text: "Loading visits...");
        }
        if (state is PastVisitsFailed) {
          return CenterErrorWidget(error: state.errorMessage);
        }
        return Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Text(
                        'Visits',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      if (state is PastVisitsSuccess) ...[
                        const GapH(8.0),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          child: Text(
                            "${pastVisitsCubit.pastVisits.pagination.totalItems}",
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w600,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const GapH(8.0),
                // Status Filter Dropdown
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18.0),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus ?? 'All',
                      hint: Text(
                        'Status',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontSize: 12.0,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      icon: Icon(
                        Icons.keyboard_arrow_down,
                        size: 16.0,
                        color: theme.colorScheme.primary,
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 12.0,
                        fontWeight: FontWeight.w500,
                        color: theme.colorScheme.primary,
                      ),
                      items: _statusOptions.map((String status) {
                        return DropdownMenuItem<String>(
                          value: status,
                          child: Text(
                            status,
                            style: TextStyle(
                              fontSize: 12.0,
                              fontWeight: FontWeight.w500,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: _onStatusChanged,
                    ),
                  ),
                ),
                const GapH(8.0),
                IconButton(
                  onPressed: () {
                    _currentPage = 1;
                    pastVisitsCubit.getGeneralPastVisits(
                      pageNumber: 1,
                      leadStatus: _selectedStatus == 'All'
                          ? null
                          : _selectedStatus,
                    );
                  },
                  icon: Icon(Icons.refresh_outlined, size: 18.0),
                  color: theme.colorScheme.primary,
                  constraints: const BoxConstraints(),
                ),
              ],
            ).pSymmetric(vertical: 8).pLeft(16),
            Expanded(
              child:
                  state is PastVisitsSuccess ||
                      (state is PastVisitsLoading && !state.isFirstPage)
                  ? _buildVisitsList(state)
                  : const Center(child: Text('No data available')),
            ),
          ],
        );
      },
    ).pBottom(100);
  }

  Widget _buildVisitsList(PastVisitsState state) {
    final visits = pastVisitsCubit.pastVisits.visits;
    final hasMoreData =
        state is PastVisitsSuccess &&
        _currentPage < pastVisitsCubit.pastVisits.pagination.totalPages;
    final isLoadingMore = state is PastVisitsLoading && !state.isFirstPage;

    if (visits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 48.0, color: Colors.grey),
            GapV(8.0),
            Text(
              'No Past Visits found',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(
        horizontal: 16.0,
      ), // Removed top padding
      itemCount: visits.length + (hasMoreData || isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < visits.length) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PastVisitDetailsScreen(visit: visits[index]),
                  ),
                );
              },
              child: IgnorePointer(
                child: LeadsCard(
                  lead: visits[index].lead,
                  time: DateFormat(
                    'MMM dd, yyyy - hh:mm a',
                  ).format(visits[index].checkInTime),
                ),
              ),
            ),
          );
        }
        if (index == visits.length && (hasMoreData || isLoadingMore)) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: isLoadingMore
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        CircularProgressIndicator(
                          strokeWidth: 3.0,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                        const GapV(8.0),
                        Text(
                          'Loading more visits...',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontSize: 14.0,
                            fontWeight: FontWeight.w500,
                            color: theme.colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: TextButton(
                      onPressed: _loadMoreVisits,
                      child: Text(
                        'Load More',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontSize: 14.0,
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                  ),
          );
        }
        return const SizedBox();
      },
    );
  }
}
