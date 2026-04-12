import 'package:go_router/go_router.dart';
import 'package:track/src/features/authentication/presentation/change_password/view/change_password_view.dart';
import 'package:track/src/features/authentication/presentation/firstPage/view/first_page_view.dart';
import 'package:track/src/features/authentication/presentation/login/view/login_view.dart';
import 'package:track/src/features/authentication/presentation/register/view/register_view.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/view/forgot_password_view.dart';
import 'package:track/src/features/authentication/presentation/register/view/send_otp_view.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/view/verify_email_view.dart';
import 'package:flutter/material.dart';
import 'package:track/src/features/dashboard/presentation/chats/views/chats_screen.dart';
import 'package:track/src/features/dashboard/presentation/tabs/views/tabs_view.dart';
import 'package:track/src/features/edit_profile/presentation/view/edit_profile_view.dart';
import 'package:track/src/features/splash/presentation/splash_screen/view/splash_view.dart';
import 'package:track/src/features/visits/domain/entities/leads_entity.dart';
import 'package:track/src/features/visits/presentation/leads/views/add_lead_view.dart';
import 'package:track/src/features/visits/presentation/leads/views/leads_map_view.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/choose_contract_view.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/docuseal_sign_view.dart';
import 'package:track/src/features/visits/presentation/sign_contract/views/sign_contract_view.dart';
import 'package:track/src/features/visits/presentation/visit_log/views/visit_log_view.dart';
import 'package:track/src/core/services/auth_service.dart';
import 'package:track/src/core/injector/injector.dart';
import 'dart:developer';

class UnfocusNavigatorObserver extends NavigatorObserver {
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    FocusScope.of(navigator!.context).unfocus();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    FocusScope.of(navigator!.context).unfocus();
  }
}

/// Route names for the application
/// Organized by feature: Authentication, Dashboard, Visits, Profile
class RouteNames {
  // ============ PUBLIC ROUTES (No Authentication Required) ============

  // Onboarding & Auth
  static const String splash = 'splash';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String verifyEmail = 'verify-email';
  static const String sendOtp = 'send-otp';
  static const String forgotPassword = 'forgot-password';

  // ============ PROTECTED ROUTES (Authentication Required) ============

  // Dashboard & Home
  static const String home = 'home';
  static const String dashboard = 'dashboard';
  static const String tabs = 'tabs';

  // Profile Management
  static const String profile = 'profile';
  static const String editProfile = 'edit-profile';
  static const String changePassword = 'change-password';

  // Visits & Leads
  static const String leads = 'leads';
  static const String addLead = 'add-lead';
  static const String leadsMap = 'leads-map';
  static const String visitLog = 'visit-log';

  // Contracts
  static const String contracts = 'contracts';
  static const String chooseContract = 'choose-contract';
  static const String signContract = 'sign-contract';
  static const String docusealSign = 'docuseal-sign';

  // Communication
  static const String chat = 'chat';
  static const String chatWithManager = 'chat-with-manager';

  // Error
  static const String notFound = 'not-found';
}

/// Route paths for the application
class RoutePaths {
  // ============ PUBLIC ROUTES ============
  static const String splash = '/';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String verifyEmail = '/verify-email';
  static const String sendOtp = '/send-otp';
  static const String forgotPassword = '/forgot-password';

  // ============ PROTECTED ROUTES ============
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String tabs = '/tabs';

  static const String profile = '/profile';
  static const String editProfile = '/profile/edit';
  static const String changePassword = '/profile/change-password';

  static const String leads = '/leads';
  static const String addLead = '/leads/add';
  static const String leadsMap = '/leads/map';
  static const String visitLog = '/visits/log';

  static const String contracts = '/contracts';
  static const String chooseContract = '/contracts/choose';
  static const String signContract = '/contracts/sign';
  static const String docusealSign = '/contracts/docuseal-sign';

  static const String chat = '/chat';
  static const String chatWithManager = '/chat/manager';

  static const String notFound = '/404';
}

class Routes {
  bool isAppLockOn = false;

  void setIsAppLockOn(bool value) {
    isAppLockOn = value;
  }

  /// List of public routes that don't require authentication
  static final Set<String> publicRoutes = {
    RoutePaths.splash,
    RoutePaths.welcome,
    RoutePaths.login,
    RoutePaths.register,
    RoutePaths.verifyEmail,
    RoutePaths.sendOtp,
    RoutePaths.forgotPassword,
    RoutePaths.notFound,
  };

  /// List of protected routes that require authentication
  static final Set<String> protectedRoutes = {
    RoutePaths.home,
    RoutePaths.dashboard,
    RoutePaths.tabs,
    RoutePaths.profile,
    RoutePaths.editProfile,
    RoutePaths.changePassword,
    RoutePaths.leads,
    RoutePaths.addLead,
    RoutePaths.leadsMap,
    RoutePaths.visitLog,
    RoutePaths.contracts,
    RoutePaths.chooseContract,
    RoutePaths.signContract,
    RoutePaths.docusealSign,
    RoutePaths.chat,
    RoutePaths.chatWithManager,
  };

  /// Check if a route requires authentication
  static bool isProtectedRoute(String path) {
    // Normalize path (remove trailing slash, query params, fragments)
    final normalizedPath = path.split('?').first.split('#').first;
    final cleanPath = normalizedPath.endsWith('/') && normalizedPath.length > 1
        ? normalizedPath.substring(0, normalizedPath.length - 1)
        : normalizedPath;

    return protectedRoutes.contains(cleanPath);
  }

  /// Check if a route is public (no authentication needed)
  static bool isPublicRoute(String path) {
    final normalizedPath = path.split('?').first.split('#').first;
    final cleanPath = normalizedPath.endsWith('/') && normalizedPath.length > 1
        ? normalizedPath.substring(0, normalizedPath.length - 1)
        : normalizedPath;

    return publicRoutes.contains(cleanPath);
  }

  /// Check if route exists in the app
  static bool isRouteExists(String path) {
    final normalizedPath = path.split('?').first.split('#').first;
    final cleanPath = normalizedPath.endsWith('/') && normalizedPath.length > 1
        ? normalizedPath.substring(0, normalizedPath.length - 1)
        : normalizedPath;

    return publicRoutes.contains(cleanPath) || protectedRoutes.contains(cleanPath);
  }

  // Legacy route constants for backward compatibility
  // TODO: Migrate all usages to RoutePaths
  @Deprecated('Use RoutePaths.splash instead')
  static const String splash = '/';
  @Deprecated('Use RoutePaths.welcome instead')
  static const String firstPage = '/welcome';
  @Deprecated('Use RoutePaths.login instead')
  static const String login = '/login';
  @Deprecated('Use RoutePaths.register instead')
  static const String register = '/register';
  @Deprecated('Use RoutePaths.verifyEmail instead')
  static const String verifyEmail = '/verify-email';
  @Deprecated('Use RoutePaths.forgotPassword instead')
  static const String forgotPassword = '/forgot-password';
  @Deprecated('Use RoutePaths.sendOtp instead')
  static const String sendOTPConfirmation = '/send-otp';
  @Deprecated('Use RoutePaths.tabs instead')
  static const String tabs = '/tabs';
  @Deprecated('Use RoutePaths.changePassword instead')
  static const String changePassword = '/profile/change-password';
  @Deprecated('Use RoutePaths.editProfile instead')
  static const String editProfile = '/profile/edit';
  @Deprecated('Use RoutePaths.visitLog instead')
  static const String visitLogView = '/visits/log';
  @Deprecated('Use RoutePaths.chooseContract instead')
  static const String chooseContractTemplate = '/contracts/choose';
  @Deprecated('Use RoutePaths.signContract instead')
  static const String signContractView = '/contracts/sign';
  @Deprecated('Use RoutePaths.chatWithManager instead')
  static const String chatWithManger = '/chat/manager';
  @Deprecated('Use RoutePaths.addLead instead')
  static const String addLead = '/leads/add';
  @Deprecated('Use RoutePaths.leadsMap instead')
  static const String leadsMapView = '/leads/map';

  GoRouter get router => GoRouter(
    initialLocation: RoutePaths.splash,
    routes: [
      // ============ PUBLIC ROUTES (No Authentication Required) ============

      // Splash & Onboarding
      GoRoute(
        path: RoutePaths.splash,
        name: RouteNames.splash,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: RoutePaths.welcome,
        name: RouteNames.welcome,
        builder: (context, state) => const FirstPageView(),
      ),

      // Authentication Routes
      GoRoute(
        path: RoutePaths.login,
        name: RouteNames.login,
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: RoutePaths.register,
        name: RouteNames.register,
        builder: (context, state) => const RegisterView(),
      ),
      GoRoute(
        path: RoutePaths.sendOtp,
        name: RouteNames.sendOtp,
        builder: (context, state) =>
            SendOtpView(email: (state.extra as String?) ?? ''),
      ),
      GoRoute(
        path: RoutePaths.verifyEmail,
        name: RouteNames.verifyEmail,
        builder: (context, state) =>
            VerifyEmailView(email: (state.extra as String?) ?? ''),
      ),
      GoRoute(
        path: RoutePaths.forgotPassword,
        name: RouteNames.forgotPassword,
        builder: (context, state) =>
            ForgotPasswordView(email: (state.extra as String?) ?? ''),
      ),

      // ============ PROTECTED ROUTES (Authentication Required) ============

      // Dashboard & Home
      GoRoute(
        path: RoutePaths.home,
        name: RouteNames.home,
        builder: (context, state) => const TabsView(),
      ),
      GoRoute(
        path: RoutePaths.tabs,
        name: RouteNames.tabs,
        builder: (context, state) => const TabsView(),
      ),

      // Profile Management
      GoRoute(
        path: RoutePaths.changePassword,
        name: RouteNames.changePassword,
        builder: (context, state) => ChangePasswordView(),
      ),
      GoRoute(
        path: RoutePaths.editProfile,
        name: RouteNames.editProfile,
        builder: (context, state) => EditProfileView(),
      ),

      // Leads Management
      GoRoute(
        path: RoutePaths.addLead,
        name: RouteNames.addLead,
        builder: (context, state) => AddLeadView(),
      ),
      GoRoute(
        path: RoutePaths.leadsMap,
        name: RouteNames.leadsMap,
        builder: (context, state) =>
            LeadsMapWidget(leads: state.extra as List<LeadsDetailsEntity>),
      ),

      // Visits
      GoRoute(
        path: RoutePaths.visitLog,
        name: RouteNames.visitLog,
        builder: (context, state) {
          final extra = state.extra as LeadIDVisitIDPageParams;
          return VisitLogView(params: extra);
        },
      ),

      // Contracts
      GoRoute(
        path: RoutePaths.chooseContract,
        name: RouteNames.chooseContract,
        builder: (context, state) =>
            ChooseContractView(params: state.extra as LeadIDVisitIDPageParams),
      ),
      GoRoute(
        path: RoutePaths.signContract,
        name: RouteNames.signContract,
        builder: (context, state) =>
            SignContractView(params: state.extra as SignContractViewPageParams),
      ),
      GoRoute(
        path: RoutePaths.docusealSign,
        name: RouteNames.docusealSign,
        builder: (context, state) =>
            DocuSealSignView(params: state.extra as DocuSealSignViewParams),
      ),

      // Communication
      GoRoute(
        path: RoutePaths.chatWithManager,
        name: RouteNames.chatWithManager,
        builder: (context, state) => ChatScreen(),
      ),
    ],
    requestFocus: false,
    redirect: (context, state) async {
      final authService = sl<AuthService>();
      final currentPath = state.uri.path;
      final isAuthenticated = await authService.isAuthenticated();

      log('🔀 Router: Navigating to $currentPath, authenticated: $isAuthenticated');

      // Allow splash screen to handle initial navigation
      if (currentPath == RoutePaths.splash) {
        log('🔀 Router: On splash path, allowing it to handle navigation');
        return null;
      }

      // Check if route exists, if not redirect to 404
      if (!isRouteExists(currentPath)) {
        log('Router: Route not found - $currentPath');
        // Redirect unknown routes to login if not authenticated, or tabs if authenticated
        return isAuthenticated ? RoutePaths.tabs : RoutePaths.login;
      }

      // If user is not authenticated and trying to access protected route
      if (!isAuthenticated && isProtectedRoute(currentPath)) {
        log('Router: Redirecting to login - protected route requires authentication');
        return RoutePaths.login;
      }

      // If user is authenticated and trying to access login/register/welcome
      // Redirect to home page
      if (isAuthenticated &&
          (currentPath == RoutePaths.login ||
              currentPath == RoutePaths.register ||
              currentPath == RoutePaths.welcome)) {
        log('Router: Redirecting to home - user already authenticated');
        return RoutePaths.tabs;
      }

      // Allow navigation
      return null;
    },
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(
        title: const Text('Page Not Found'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            // Try to go back, or go to home if can't go back
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go(RoutePaths.tabs);
            }
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            const Text(
              'Page Not Found',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'The page "${state.uri.path}" does not exist.',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.go(RoutePaths.tabs),
              icon: const Icon(Icons.home),
              label: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    ),
  );
}
