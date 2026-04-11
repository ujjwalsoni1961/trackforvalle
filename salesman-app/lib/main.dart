// import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/firebase_options.dart';
import 'package:track/src/core/network/notification_helper.dart';
// import 'package:provider/provider.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/send_otp_cubit.dart';
import 'package:track/src/core/injector/injector.dart';
import 'package:track/src/core/local/hive_config.dart';
// import 'package:track/src/core/network/network_status.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/res/app_themes.dart';
import 'package:track/src/features/authentication/presentation/change_password/cubit/change_password_cubit.dart';
import 'package:track/src/features/authentication/presentation/firstPage/cubit/first_page_cubit.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/cubit/forgot_password_cubit.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/cubit/forgot_password_timer_cubit.dart';
import 'package:track/src/features/authentication/presentation/login/cubit/login_cubit.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/register_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_otp_timer_cubit.dart';
import 'package:track/src/features/dashboard/presentation/chats/views/firebase_chat_utils_manager.dart';
import 'package:track/src/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
import 'package:track/src/features/dashboard/presentation/profile/cubit/profile_details_cubit.dart';
import 'package:track/src/features/dashboard/presentation/tabs/cubit/tab_change_cubit.dart';
import 'package:track/src/features/edit_profile/presentation/cubit/edit_profile_cubit.dart';
import 'package:track/src/features/splash/presentation/splash_screen/cubit/app_configuration_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/daily_routes_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/get_current_location_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/plan_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/add_lead_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/edit_a_lead_details_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/lead_id_past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/regions_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/sub_regions_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/get_contract_templates_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/submit_contract_cubit.dart';
import 'package:track/src/features/visits/presentation/visit_log/cubit/visit_log_cubit.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await FirebaseNotificationManager.init();
    await FirebaseChatUtilsManager.autheticate();
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
  }

  // Initialize dependencies first
  await injectDependencies();

  // Then initialize Hive to ensure all boxes are ready before app starts
  await HiveConfig.init();

  final Routes routes = Routes();
  routes.setIsAppLockOn(false);
  runApp(MyApp(router: routes.router));
}

class MyApp extends StatefulWidget {
  final GoRouter router;
  const MyApp({super.key, required this.router});
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (context) => sl<RegisterCubit>()),
        BlocProvider(create: (context) => sl<SendOtpCubit>()),
        BlocProvider(create: (context) => sl<VerifyEmailCubit>()),
        BlocProvider(create: (context) => sl<LoginCubit>()),
        BlocProvider(create: (context) => sl<FirstPageCubit>()),
        BlocProvider(create: (context) => sl<ForgotPasswordCubit>()),
        BlocProvider(create: (context) => sl<ChangePasswordCubit>()),
        BlocProvider(create: (context) => sl<ForgotPasswordTimerCubit>()),
        BlocProvider(create: (context) => sl<VerifyEmailOtpTimerCubit>()),
        BlocProvider(create: (context) => sl<AppConfigurationCubit>()),
        BlocProvider(create: (context) => sl<ProfileDetailsCubit>()),
        BlocProvider(create: (context) => sl<EditProfileCubit>()),
        BlocProvider(create: (context) => sl<LeadsDetailsCubit>()),
        BlocProvider(create: (context) => sl<LeadStatusCubit>()),
        BlocProvider(create: (context) => sl<EditALeadDetailsCubit>()),
        BlocProvider(create: (context) => sl<TabChangeCubit>()),
        BlocProvider(create: (context) => sl<DailyRoutesCubit>()),
        BlocProvider(create: (context) => sl<GetCurrentLocationCubit>()),
        BlocProvider(create: (context) => sl<AddLeadCubit>()),
        BlocProvider(create: (context) => sl<VisitLogCubit>()),
        BlocProvider(create: (context) => sl<GetContractTemplatesCubit>()),
        BlocProvider(create: (context) => sl<SubmitContractCubit>()),
        BlocProvider(create: (context) => sl<PastVisitsCubit>()),
        BlocProvider(create: (context) => sl<PlanVisitsCubit>()),
        BlocProvider(create: (context) => sl<LeadIdPastVisitsCubit>()),
        BlocProvider(create: (context) => sl<DashboardCubit>()),
        BlocProvider(create: (context) => sl<RegionsCubit>()),
        BlocProvider(create: (context) => sl<SubRegionsCubit>()),
      ],
      child: MaterialApp.router(
        title: 'Track',
        theme: AppThemes.lightTheme,
        key: navigatorKey,
        darkTheme: AppThemes.lightTheme,
        themeMode: ThemeMode.dark,
        debugShowCheckedModeBanner: false,
        routerConfig: widget.router,
        builder: (context, child) {
          return Container(
            color: const Color(0xFFE8EAF0),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 600),
                child: child,
              ),
            ),
          );
        },
      ),
    );
  }
}
