import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/features/authentication/presentation/login/cubit/login_cubit.dart';

class ForgotPasswordWidget extends StatefulWidget {
  const ForgotPasswordWidget({super.key});

  @override
  State<ForgotPasswordWidget> createState() => _ForgotPasswordWidgetState();
}

class _ForgotPasswordWidgetState extends State<ForgotPasswordWidget> {
  late LoginCubit loginCubit = context.read<LoginCubit>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerRight,
      child: InkWell(
        onTap: () {
          context.push(Routes.forgotPassword);
        },
        child: Text(
          'Forgot Password?',
          style: theme.textTheme.labelMedium,
        ).pSymmetric(horizontal: 4),
      ).pSymmetric(horizontal: 24, vertical: 8),
    );
  }
}
