import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/paddings.dart';

class CreateAnAccount extends StatelessWidget {
  const CreateAnAccount({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Align(
      alignment: Alignment.center,
      child: InkWell(
        onTap: () {
          context.push(Routes.register);
        },
        child: Text(
          'Create an account ? ',
          style: theme.textTheme.bodyLarge!.copyWith(
            color: theme.colorScheme.tertiary,
          ),
        ).pSymmetric(horizontal: 4),
      ).defaultPadding(),
    );
  }
}
