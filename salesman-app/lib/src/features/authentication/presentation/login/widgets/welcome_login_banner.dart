import 'package:flutter/material.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class WelcomeLoginBanner extends StatelessWidget {
  const WelcomeLoginBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GapV(40),
        Align(
          alignment: Alignment.center,
          child: Column(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.accent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.track_changes,
                  color: Colors.white,
                  size: 36,
                ),
              ),
              const GapV(12),
              Text(
                'Track',
                style: theme.textTheme.titleLarge?.copyWith(
                  color: AppColors.accent,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
            ],
          ),
        ),
        const GapV(40),
        Text(
          'Welcome back',
          style: theme.textTheme.displayMedium?.copyWith(
            fontSize: 28,
          ),
        ).pSymmetric(horizontal: 16),
        const GapV(8),
        Wrap(
          children: [
            Text(
              'Sign in to your account to continue.',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w400,
                fontSize: 14,
              ),
              softWrap: true,
            ),
          ],
        ).defaultPadding(),
      ],
    );
  }
}
