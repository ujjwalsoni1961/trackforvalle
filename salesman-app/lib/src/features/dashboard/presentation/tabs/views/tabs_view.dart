// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/user_local_data_source.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/line_seperator.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
import 'package:track/src/features/dashboard/presentation/home/views/home_tab.dart';
import 'package:track/src/features/dashboard/presentation/profile/cubit/profile_details_cubit.dart';
import 'package:track/src/features/dashboard/presentation/profile/views/profile_tab.dart';
import 'package:track/src/features/dashboard/presentation/tabs/cubit/tab_change_cubit.dart';
import 'package:track/src/features/dashboard/presentation/tabs/widgets/custom_bottom_bar.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/views/all_leads_details_view.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/regions_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/get_contract_templates_cubit.dart';

class TabsView extends StatefulWidget {
  const TabsView({super.key});

  @override
  State<TabsView> createState() => _TabsViewState();
}

class _TabsViewState extends State<TabsView>
    with SingleTickerProviderStateMixin {
  late TabController tabController = TabController(length: 3, vsync: this);
  late final TabChangeCubit tabChangeCubit = context.read<TabChangeCubit>();

  late final ThemeData theme = Theme.of(context);

  @override
  void initState() {
    super.initState();

    tabController.addListener(() {
      tabChangeCubit.changeTab(tabController.index);
    });

    // Initialize data on first load (important for browser refresh/direct navigation)
    _initializeData();
  }

  void _initializeData() {
    // Fetch all necessary data for the app
    context.read<LeadStatusCubit>().getTheLeadStatusList();
    context.read<RegionsCubit>().getTheRegion();
    context.read<DashboardCubit>().getTheDashBoardData();
    context.read<ProfileDetailsCubit>().fetchProfileDetailsLocal();
    context.read<LeadsDetailsCubit>().getAllTheLeads(pageNumber: 1);
    context.read<GetContractTemplatesCubit>().getTheContractTemplates();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<LeadsDetailsCubit, LeadsDetailsState>(
          listener: (context, leadsState) async {
            if (leadsState is LeadsDetailsFailed) {
              final res = await sl<UserLocalDataSource>().removeUserData();
              res.fold(
                (failure) {
                  context.errorBar("Unauthorized");
                },
                (_) {
                  context.errorBar("Unauthorized");
                  context.go(Routes.firstPage);
                },
              );
            }
          },
        ),
      ],
      child: BlocConsumer<TabChangeCubit, TabChangeState>(
        listener: (context, state) {
          if (state is TabChange) {
            tabController.animateTo(state.tabIndex);
          }
        },
        builder: (context, state) {
          return WillPopScope(
            onWillPop: () {
              if (tabChangeCubit.tabIndex == 0) {
                return Future.value(true);
              }
              tabChangeCubit.changeTab(0);
              return Future.value(false);
            },
            child: MyScaffold(
              appBar: AppBar(
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Image.asset('assets/images/logo.png', height: 32).pRight(8),
                    const Text('Track'),
                  ],
                ),
                elevation: 0,
                bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(1),
                  child: const LineSeperator().pSymmetric(horizontal: 4),
                ),
              ),
              resizeToAvoidBottomInset: false,
              hideKeyboardOnTap: true,
              body: TabBarView(
                controller: tabController,
                physics:
                    const NeverScrollableScrollPhysics(),
                children: [
                  HomeTabView(),
                  AllLeadsDetailsView(),
                  ProfileTab(),
                ],
              ),
              bottomBar: CustomBottomAppBar(
                currentIndex: tabController.index,
                onTap: (index) {
                  tabChangeCubit.changeTab(index);
                },
                items: const [
                  TabItem(label: 'Home', icon: AppIcons.home),
                  TabItem(label: 'Leads', icon: AppIcons.continueIcon),
                  TabItem(label: 'Profile', icon: AppIcons.profile),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
