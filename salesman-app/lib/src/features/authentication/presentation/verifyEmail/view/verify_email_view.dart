import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/widgets/form_manager.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/send_otp_cubit.dart';
import 'package:track/src/core/ui/res/app_assets.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_otp_timer_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/widgets/verify_otp_text_feilds.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/widgets/verify_email_resend_otp_widget.dart';

class VerifyEmailView extends StatefulWidget {
  final String email;
  const VerifyEmailView({super.key, required this.email});

  @override
  State<VerifyEmailView> createState() => _VerifyEmailViewState();
}

class _VerifyEmailViewState extends State<VerifyEmailView> {
  late VerifyEmailCubit verifyEmailCubit = context.read<VerifyEmailCubit>();
  late VerifyEmailOtpTimerCubit verifyEmailOtpTimerCubit = context
      .read<VerifyEmailOtpTimerCubit>();
  late SendOtpCubit sendOtpCubit = context.read<SendOtpCubit>();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final TextEditingController otpController = TextEditingController();
  FocusScopeNode focusScopeNode = FocusScopeNode();
  bool isFromRegister = false;

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return MyScaffold(
      title: 'Verify Email',
      body: BlocConsumer<VerifyEmailCubit, VerifyEmailState>(
        listener: (context, state) {
          if (state is EmailVerifying) {
            LoadingAnimation.show(context);
          }
          if (state is EmailVerified) {
            context.pop();
            context.go(Routes.splash);
          }
          if (state is EmailVerificationFailed) {
            context.pop();
            context.errorBar(state.errorMessage);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const GapV(16),
                Align(
                  alignment: Alignment.center,
                  child: Image.asset(
                    AppAssets.verifyOtp,
                    height: 160,
                    fit: BoxFit.fill,
                  ),
                ),
                const GapV(36),
                VerifyEmailOtpTextFeilds(controller: otpController),
                const GapV(8),
                Align(
                  alignment: Alignment.centerRight,
                  child: VerifyEmailResendOTPWidget(email: widget.email),
                ),
                const GapV(32),
                Text(
                  "A mail is sent to your email with a 6 digit code.Please enter the code to verify your email",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    color: theme.colorScheme.tertiary,
                  ),
                  textAlign: TextAlign.center,
                ).defaultPadding(),
                const GapV(64),
                ButtonPrimary(
                  text: "Verify",
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    focusScopeNode.unfocus();
                    verifyEmailCubit.verifyEmailWithOtp(
                      email: widget.email,
                      otp: otpController.text,
                    );
                  },
                ),
                const GapV(8),
              ],
            ).makeItForm(formKey, focusScopeNode),
          );
        },
      ),
    );
  }
}
