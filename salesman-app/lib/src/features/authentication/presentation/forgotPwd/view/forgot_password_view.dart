import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/validator.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/form_manager.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/cubit/forgot_password_cubit.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/cubit/forgot_password_timer_cubit.dart';
import 'package:track/src/features/authentication/presentation/forgotPwd/widgets/forgot_pwd_banner.dart';

class ForgotPasswordView extends StatefulWidget {
  final String email;
  const ForgotPasswordView({super.key, required this.email});

  @override
  State<ForgotPasswordView> createState() => _ForgotPasswordViewState();
}

class _ForgotPasswordViewState extends State<ForgotPasswordView> {
  late ForgotPasswordCubit forgotPasswordCubit = context
      .read<ForgotPasswordCubit>();
  late ThemeData theme = Theme.of(context);
  late ForgotPasswordTimerCubit forgotPasswordTimerCubit = context
      .read<ForgotPasswordTimerCubit>();
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusScopeNode focusScopeNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: 'Forgot Password',
      hideKeyboardOnTap: true,
      body: BlocConsumer<ForgotPasswordCubit, ForgotPasswordState>(
        listener: (context, state) {
          if (state is SendingOTP) {
            LoadingAnimation.show(context);
          }
          if (state is OTPSent) {
            context.pop();
            context.successBar("Password reset link sent to your email");
            context.pop();
          }
          if (state is OTPSendingFailed) {
            context.pop();
            context.errorBar(state.errorMessage);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              children: [
                const ForgotPasswordBanner(showHint: true),
                const Gap(16),
                TextFormField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return 'Please enter an email';
                    } else if (!Validator.validateEmail(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Transform.scale(
                      scale: 0.4,
                      child: context.icon(
                        AppIcons.email,
                        color: theme.iconTheme.color,
                      ),
                    ),
                  ),
                ).defaultPadding(),
                const GapV(16),
                ButtonPrimary(
                  text: 'Send OTP',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    focusScopeNode.unfocus();
                    forgotPasswordCubit.sendForgotPasswordOtp(
                      emailController.text.trim(),
                      false,
                    );
                  },
                ),
              ],
            ).makeItForm(formKey, focusScopeNode),
          );
        },
      ),
    );
  }
}
