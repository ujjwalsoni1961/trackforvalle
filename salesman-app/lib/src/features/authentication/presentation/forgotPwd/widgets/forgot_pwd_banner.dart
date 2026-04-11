import 'package:flutter/material.dart';
import 'package:track/src/core/ui/res/app_assets.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/visible_if.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class ForgotPasswordBanner extends StatelessWidget {
  final bool? showHint;
  const ForgotPasswordBanner({super.key, this.showHint});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const GapV(16),
        Align(
          alignment: Alignment.center,
          child: Image.asset(
            AppAssets.forgotPassword,
            height: 160,
            fit: BoxFit.fill,
          ),
        ),
        const GapV(36),
        Text(
          "Don't worry,",
          style: theme.textTheme.displayMedium,
        ).pSymmetric(horizontal: 16).visibleIf(showHint ?? false),
        Wrap(
          children: [
            Text(
              "Please provide your email address, and we'll send an email to reset your password.",
              style: theme.textTheme.bodyMedium!.copyWith(
                color: theme.colorScheme.tertiary,
                fontWeight: FontWeight.w500,
              ),
              softWrap: true,
            ),
          ],
        ).defaultPadding().visibleIf(showHint ?? false),
      ],
    );
  }
}
