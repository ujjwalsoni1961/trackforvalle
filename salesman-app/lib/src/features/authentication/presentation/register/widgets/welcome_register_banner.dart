import 'package:flutter/material.dart';
import 'package:track/src/core/ui/res/app_assets.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class RegisterBanner extends StatelessWidget {
  const RegisterBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GapV(16),
        Align(
          alignment: Alignment.center,
          child: Image.asset(AppAssets.register, height: 160, fit: BoxFit.fill),
        ),
        const GapV(36),
        Text(
          'Welcome aboard,',
          style: theme.textTheme.displayMedium,
        ).pSymmetric(horizontal: 16),
        Wrap(
          children: [
            Text(
              'We’re thrilled to welcome you! Set up your account now to begin your journey with us.',
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
            ),
          ],
        ).defaultPadding(),
      ],
    );
  }
}
