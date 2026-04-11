// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/center_loading_text_widget.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/center_error_widget.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/get_current_location_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/plan_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/add_lead_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/edit_a_lead_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/widgets/leads_card.dart';
import 'package:track/src/features/visits/presentation/visit_log/cubit/visit_log_cubit.dart';
import 'dart:async';

class AllLeadsDetailsView extends StatefulWidget {
  const AllLeadsDetailsView({super.key});

  @override
  State<AllLeadsDetailsView> createState() => _AllLeadsDetailsViewState();
}

class _AllLeadsDetailsViewState extends State<AllLeadsDetailsView> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final LeadsDetailsCubit leadsDetailsCubit = context
      .read<LeadsDetailsCubit>();
  late final PlanVisitsCubit planVisitCubit = context.read<PlanVisitsCubit>();
  late ThemeData theme = Theme.of(context);
  bool _isSearchExpanded = false;
  Timer? _debounce;
  List<int> selectedLeadIds = [];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
              _scrollController.position.maxScrollExtent - 200 &&
          !_scrollController.position.outOfRange) {
        leadsDetailsCubit.loadMoreLeads();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _toggleSearch() {
    setState(() {
      _isSearchExpanded = !_isSearchExpanded;
      if (!_isSearchExpanded) {
        _searchController.clear();
        leadsDetailsCubit.refreshLeads();
      }
    });
  }

  void _onSearchChanged(String value) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () {
      leadsDetailsCubit.searchLeads(value.toLowerCase());
    });
  }

  void _showMoreActionsSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16.0)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const GapV(16.0),
            Text(
              'Lead Actions',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const GapV(16.0),
            _ActionTile(
              icon: Icons.add,
              title: 'Add Lead',
              onTap: () {
                Navigator.pop(context);
                context.push(Routes.addLead);
              },
            ),
            _ActionTile(
              icon: Icons.location_on_outlined,
              title: 'View leads on maps',
              onTap: () {
                Navigator.pop(context);
                context.push(
                  Routes.leadsMapView,
                  extra: leadsDetailsCubit.leadsData.allLeads,
                );
              },
            ),
            _ActionTile(
              icon: Icons.refresh,
              title: 'Refresh Data',
              onTap: () {
                Navigator.pop(context);
                leadsDetailsCubit.refreshLeads();
              },
            ),
            const GapV(16.0),
          ],
        ),
      ),
    );
  }

  void _onLeadSelectionChanged(int leadId, bool isSelected) {
    setState(() {
      if (isSelected) {
        if (!selectedLeadIds.contains(leadId)) {
          selectedLeadIds.add(leadId);
        }
      } else {
        selectedLeadIds.remove(leadId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<PlanVisitsCubit, PlanVisitsState>(
          listener: (context, state) {
            if (state is PlanVisitsFailed) {
              context.errorBar(state.errorMessage);
            }
            if (state is PlanVisitsSuccess) {
              selectedLeadIds = [];
              context.successBar("Visits Planned successfully");
              leadsDetailsCubit.refreshLeads();
              context.read<GetCurrentLocationCubit>().getCurrentLatLong(
                refreshRoutes: true,
              );
              context.read<DashboardCubit>().getTheDashBoardData();
            }
          },
        ),
        BlocListener<AddLeadCubit, AddLeadState>(
          listener: (context, state) {
            if (state is AddLeadSuccess) {
              leadsDetailsCubit.refreshLeads();
              context.read<DashboardCubit>().getTheDashBoardData();
            }
          },
        ),
        BlocListener<EditALeadDetailsCubit, EditALeadDetailsState>(
          listener: (context, state) {
            if (state is EditALeadDetailsSuccess) {
              leadsDetailsCubit.refreshLeads();
              context.read<DashboardCubit>().getTheDashBoardData();
            }
          },
        ),
        BlocListener<VisitLogCubit, VisitLogState>(
          listener: (context, state) {
            if (state is VisitLogSuccess) {
              leadsDetailsCubit.refreshLeads();
              context.read<DashboardCubit>().getTheDashBoardData();
            }
          },
        ),
      ],
      child: BlocBuilder<LeadsDetailsCubit, LeadsDetailsState>(
        builder: (context, state) {
          if (state is LeadsDetailsLoading && state.isFirstPage) {
            return const CenterLoadingTextWidget(text: "Loading leads...");
          }
          if (state is LeadsDetailsFailed) {
            return CenterErrorWidget(error: state.errorMessage);
          }

          return MyScaffold(
            floatingActionButton: selectedLeadIds.isNotEmpty
                ? FloatingActionButton.extended(
                    onPressed: () async {
                      final locationCubit = context
                          .read<GetCurrentLocationCubit>();
                      await locationCubit.getCurrentLatLong();
                      planVisitCubit.planTheVisit(
                        leadIds: selectedLeadIds,
                        latitude: locationCubit.latitude ?? 0,
                        longitude: locationCubit.longitude ?? 0,
                      );
                    },
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: Text('Plan Visit (${selectedLeadIds.length})'),
                  )
                : null,
            body: Column(
              children: [
                // Header Section
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: _isSearchExpanded
                                ? _buildSearchField()
                                : _buildTitleSection(state),
                          ),
                          const GapH(12.0),
                          _buildActionButtons(),
                        ],
                      ),
                      if (!_isSearchExpanded) ...[
                        const GapV(12.0),
                        _buildCompactSearchBar(),
                      ],
                    ],
                  ),
                ),
                Expanded(
                  child:
                      (state is LeadsDetailsLoaded ||
                          (state is LeadsDetailsLoading && !state.isFirstPage))
                      ? _buildLeadsList(state)
                      : const Center(child: Text('No data available')),
                ),
              ],
            ),
          );
        },
      ).pBottom(100),
    );
  }

  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: TextField(
        controller: _searchController,
        autofocus: true,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search leads...',
          prefixIcon: Icon(
            Icons.search,
            color: theme.colorScheme.primary,
            size: 20.0,
          ),
          suffixIcon: leadsDetailsCubit.currentQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: Colors.grey, size: 20.0),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12.0),
        ),
      ),
    );
  }

  Widget _buildTitleSection(LeadsDetailsState state) {
    return Row(
      children: [
        Text(
          'Leads',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.primary,
          ),
        ),
        if (state is LeadsDetailsLoaded) ...[
          const GapH(8.0),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            decoration: BoxDecoration(
              color: theme.colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12.0),
            ),
            child: Text(
              '${state.allLeads.paginationData.total}',
              style: theme.textTheme.bodySmall?.copyWith(
                fontSize: 12.0,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons() {
    return IntrinsicHeight(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Action Icons Row
          SizedBox(
            height: 60.0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Map View Button
                if (!_isSearchExpanded)
                  _buildActionItem(
                    onPressed: () {
                      context.push(
                        Routes.leadsMapView,
                        extra: leadsDetailsCubit.leadsData.allLeads,
                      );
                    },
                    icon: Icons.location_on_outlined,
                    label: 'Map View',
                  ),

                // Refresh Button
                if (!_isSearchExpanded)
                  _buildActionItem(
                    onPressed: () {
                      leadsDetailsCubit.refreshLeads();
                    },
                    icon: Icons.refresh_outlined,
                    label: 'Refresh',
                  ),

                // Clear Search Button
                if (_isSearchExpanded)
                  _buildActionItem(
                    onPressed: _toggleSearch,
                    icon: Icons.clear,
                    label: 'Clear',
                  ),

                // More Actions Button
                if (!_isSearchExpanded)
                  _buildActionItem(
                    onPressed: _showMoreActionsSheet,
                    icon: Icons.more_vert,
                    label: 'More',
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionItem({
    required VoidCallback onPressed,
    required IconData icon,
    required String label,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 70.0,
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8.0),
          border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20.0, color: theme.colorScheme.primary),
            const SizedBox(height: 4.0),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.0,
                color: theme.colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainer.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12.0),
        border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
      ),
      child: TextField(
        onTap: () {
          setState(() {
            _isSearchExpanded = true;
          });
        },
        readOnly: true,
        decoration: InputDecoration(
          hintText: 'Search leads...',
          hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14.0),
          prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 18.0),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 10.0),
        ),
      ),
    );
  }

  Widget _buildLeadsList(LeadsDetailsState state) {
    final leads = leadsDetailsCubit.leadsData.allLeads;
    final hasMoreData = leadsDetailsCubit.hasMoreData;
    final isLoadingMore = state is LeadsDetailsLoading && !state.isFirstPage;

    if (leads.isEmpty && leadsDetailsCubit.currentQuery.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 64.0, color: Colors.grey[400]),
            const GapV(16.0),
            Text(
              'No leads found',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const GapV(8.0),
            Text(
              'Try adjusting your search terms',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[500],
              ),
            ),
          ],
        ),
      );
    }

    return BlocBuilder<DashboardCubit, DashboardState>(
      builder: (context, dashboardState) {
        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.all(16.0),
          itemCount: leads.length + (hasMoreData || isLoadingMore ? 1 : 0) + 1,
          itemBuilder: (context, index) {
            if (index == 0 && !_isSearchExpanded) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: _buildStatsCards(dashboardState),
              );
            }
            if (index >= 1 && index < leads.length + 1) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 12.0),
                child: LeadsCard(
                  lead: leads[index - 1],
                  isSelected: selectedLeadIds.contains(leads[index - 1].leadID),
                  onSelectionChanged: (isSelected) {
                    _onLeadSelectionChanged(
                      leads[index - 1].leadID,
                      isSelected,
                    );
                  },
                ),
              );
            }
            if (index == leads.length + 1 && (hasMoreData || isLoadingMore)) {
              return _buildLoadMoreSection(isLoadingMore);
            }
            return const SizedBox();
          },
        );
      },
    );
  }

  Widget _buildStatsCards(DashboardState dashboardState) {
    return Row(
      children: [
        _StatCard(
          title: 'Total',
          count: dashboardState is DashboardSuccess
              ? dashboardState.dashboardData.totalLeads
              : 0,
          color: theme.colorScheme.primary,
          icon: Icons.people_outline,
        ),
        const GapH(12.0),
        _StatCard(
          title: 'Visited',
          count: dashboardState is DashboardSuccess
              ? dashboardState.dashboardData.visitedLeads
              : 0,
          color: Colors.green,
          icon: Icons.check_circle_outline,
        ),
        const GapH(12.0),
        _StatCard(
          title: 'Remaining',
          count: dashboardState is DashboardSuccess
              ? dashboardState.dashboardData.unVisitedLeads
              : 0,
          color: Colors.orange,
          icon: Icons.schedule_outlined,
        ),
      ],
    );
  }

  Widget _buildLoadMoreSection(bool isLoadingMore) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20.0),
      child: Center(
        child: isLoadingMore
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 24.0,
                    height: 24.0,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.primary,
                      ),
                    ),
                  ),
                  const GapV(12.0),
                  Text(
                    'Loading more leads...',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )
            : OutlinedButton.icon(
                onPressed: () => leadsDetailsCubit.loadMoreLeads(),
                icon: const Icon(Icons.expand_more, size: 18.0),
                label: const Text('Load More'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20.0,
                    vertical: 12.0,
                  ),
                ),
              ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final int count;
  final Color color;
  final IconData icon;

  const _StatCard({
    required this.title,
    required this.count,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: color.withOpacity(0.2)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Icon(icon, size: 16.0, color: color),
                const GapH(6.0),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontSize: 10.0,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const GapV(8.0),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                '$count',
                style: theme.textTheme.titleLarge?.copyWith(
                  fontSize: 18.0,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: theme.colorScheme.primary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Icon(icon, color: theme.colorScheme.primary, size: 20.0),
      ),
      title: Text(
        title,
        style: theme.textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
    );
  }
}
