import 'dart:math' as dart_math;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/dashboard/presentation/home/cubit/dashboard_cubit.dart';
import 'package:track/src/features/dashboard/presentation/profile/cubit/profile_details_cubit.dart';
import 'package:track/src/features/splash/presentation/splash_screen/cubit/app_configuration_cubit.dart';
import 'package:track/src/features/visits/presentation/daily_routes/cubit/get_current_location_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/lead_status_cubit.dart';
import 'package:track/src/features/visits/presentation/leads/cubit/leads_details_cubit.dart';
import 'package:track/src/features/visits/presentation/past_visits/cubit/past_visits_cubit.dart';
import 'package:track/src/features/visits/presentation/region_subregions/cubit/regions_cubit.dart';
import 'package:track/src/features/visits/presentation/sign_contract/cubit/get_contract_templates_cubit.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with TickerProviderStateMixin {
  late GetCurrentLocationCubit getCurrentLocationCubit =
      context.read<GetCurrentLocationCubit>();
  late AnimationController _logoController;
  late AnimationController _salesmanController;
  late AnimationController _pathController;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<Offset> _salesmanSlideAnimation;
  late Animation<double> _pathAnimation;
  late Animation<double> _houseAnimation;
  late Animation<double> _signatureAnimation;

  @override
  void initState() {
    super.initState();

    // Logo animation controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Salesman animation controller
    _salesmanController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Path drawing animation controller
    _pathController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Logo animations
    _logoFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.8, curve: Curves.elasticOut),
      ),
    );

    // Salesman sliding animation
    _salesmanSlideAnimation = Tween<Offset>(
      begin: const Offset(-1.5, 0),
      end: const Offset(0.8, 0),
    ).animate(
      CurvedAnimation(
        parent: _salesmanController,
        curve: Curves.easeInOutCubic,
      ),
    );

    // Path drawing animation
    _pathAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _pathController,
        curve: Curves.easeInOut,
      ),
    );

    // House appearing animation
    _houseAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _salesmanController,
        curve: const Interval(0.5, 0.8, curve: Curves.easeOut),
      ),
    );

    // Signature animation
    _signatureAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _salesmanController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOut),
      ),
    );

    // Start animations
    _logoController.forward().then((_) {
      _pathController.forward();
      _salesmanController.forward();
    });

    // NotificationHelper.initialize();
    context.read<AppConfigurationCubit>().checkUserLoggedIn();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _salesmanController.dispose();
    _pathController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return MyScaffold(
      body: MultiBlocListener(
        listeners: [
          BlocListener<AppConfigurationCubit, AppConfigurationState>(
            listener: (context, state) {
              if (state is UserLoggedIn) {
                getCurrentLocationCubit.getCurrentLatLong(refreshRoutes: true);
                context.read<LeadStatusCubit>().getTheLeadStatusList();
                context.read<RegionsCubit>().getTheRegion();
                context.read<DashboardCubit>().getTheDashBoardData();
                context.read<ProfileDetailsCubit>().fetchProfileDetailsLocal();
                context.read<LeadsDetailsCubit>().getAllTheLeads(pageNumber: 1);
                context
                    .read<GetContractTemplatesCubit>()
                    .getTheContractTemplates();
                context.read<PastVisitsCubit>().getGeneralPastVisits(
                  pageNumber: 1,
                );
                context.go(Routes.tabs);
              }
              if (state is UserNotLoggedIn) {
                context.go(Routes.firstPage);
              }
            },
          ),
        ],
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent.withOpacity(0.1),
                AppColors.white,
                AppColors.accent.withOpacity(0.05),
              ],
            ),
          ),
          child: Stack(
            children: [
              // Animated path/route
              AnimatedBuilder(
                animation: _pathAnimation,
                builder: (context, child) {
                  return CustomPaint(
                    size: Size(size.width, size.height),
                    painter: RoutePainter(_pathAnimation.value, AppColors.accent),
                  );
                },
              ),

              // Main content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo with animation
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoFadeAnimation.value,
                          child: Transform.scale(
                            scale: _logoScaleAnimation.value,
                            child: Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.accent.withOpacity(0.3),
                                    blurRadius: 30,
                                    spreadRadius: 5,
                                  ),
                                ],
                              ),
                              child: Image.asset(
                                "assets/images/logo.png",
                                width: 120,
                                height: 120,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // Animated salesman journey scene
                    AnimatedBuilder(
                      animation: _salesmanController,
                      builder: (context, child) {
                        return SizedBox(
                          height: 200,
                          width: size.width * 0.8,
                          child: Stack(
                            children: [
                              // House at the end
                              Positioned(
                                right: 20,
                                bottom: 40,
                                child: Opacity(
                                  opacity: _houseAnimation.value,
                                  child: Icon(
                                    Icons.home,
                                    size: 80,
                                    color: AppColors.accent.withOpacity(0.7),
                                  ),
                                ),
                              ),

                              // Salesman walking
                              Positioned(
                                bottom: 40,
                                child: SlideTransition(
                                  position: _salesmanSlideAnimation,
                                  child: Column(
                                    children: [
                                      Icon(
                                        Icons.directions_walk,
                                        size: 60,
                                        color: AppColors.accent,
                                      ),
                                      const SizedBox(height: 4),
                                      Icon(
                                        Icons.phone_android,
                                        size: 24,
                                        color: AppColors.accent.withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              // Signature appearing
                              Positioned(
                                right: 30,
                                top: 20,
                                child: Opacity(
                                  opacity: _signatureAnimation.value,
                                  child: Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: AppColors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      boxShadow: [
                                        BoxShadow(
                                          color: AppColors.accent.withOpacity(0.2),
                                          blurRadius: 10,
                                        ),
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Icon(
                                          Icons.edit,
                                          size: 30,
                                          color: AppColors.accent,
                                        ),
                                        const SizedBox(height: 4),
                                        Icon(
                                          Icons.check_circle,
                                          size: 20,
                                          color: Colors.green,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 40),

                    // App name with fade in
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoFadeAnimation.value,
                          child: Column(
                            children: [
                              Text(
                                'Track',
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.accent,
                                  letterSpacing: 2,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Field Sales Made Easy',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppColors.grey,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Custom painter for the route path
class RoutePainter extends CustomPainter {
  final double progress;
  final Color color;

  RoutePainter(this.progress, this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();

    // Create a curved path from left to right
    final startX = size.width * 0.1;
    final startY = size.height * 0.6;
    final endX = size.width * 0.9;

    path.moveTo(startX, startY);

    // Create wave-like path
    for (double i = 0; i <= progress; i += 0.01) {
      final x = startX + (endX - startX) * i;
      final y = startY + 30 * Math.sin(i * Math.pi * 4);
      path.lineTo(x, y);
    }

    canvas.drawPath(path, paint);

    // Draw location markers along the path
    if (progress > 0.3) {
      final markerPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(startX + (endX - startX) * 0.3,
               startY + 30 * Math.sin(0.3 * Math.pi * 4)),
        6,
        markerPaint,
      );
    }

    if (progress > 0.6) {
      final markerPaint = Paint()
        ..color = color.withOpacity(0.5)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(
        Offset(startX + (endX - startX) * 0.6,
               startY + 30 * Math.sin(0.6 * Math.pi * 4)),
        6,
        markerPaint,
      );
    }
  }

  @override
  bool shouldRepaint(RoutePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

// Math utility for sine function
class Math {
  static double sin(double value) {
    return dart_math.sin(value);
  }

  static const double pi = dart_math.pi;
}
