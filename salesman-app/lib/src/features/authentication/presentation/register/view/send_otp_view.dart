import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/send_otp_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_otp_timer_cubit.dart';

class SendOtpView extends StatefulWidget {
  final String email;
  const SendOtpView({super.key, required this.email});

  @override
  State<SendOtpView> createState() => _SendOtpViewState();
}

class _SendOtpViewState extends State<SendOtpView> {
  late VerifyEmailCubit verifyEmailCubit = context.read<VerifyEmailCubit>();
  late VerifyEmailOtpTimerCubit verifyEmailOtpTimerCubit = context
      .read<VerifyEmailOtpTimerCubit>();
  late SendOtpCubit sendOtpCubit = context.read<SendOtpCubit>();

  late ThemeData theme = Theme.of(context);
  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "",
      body: BlocListener<SendOtpCubit, SendOtpState>(
        listener: (context, state) {
          if (state is SendingOTP) {
            LoadingAnimation.show(context);
          }
          if (state is OTPSendingFailed) {
            context.pop();
            context.errorBar(state.errorMessage);
          }
          if (state is OTPSent) {
            context.pop();
            context.successBar("OTP sent");
          }
        },
        child: Column(
          children: [
            const GapV(16),
            Text(
              'Verify your email',
              style: theme.textTheme.displaySmall,
            ).defaultPadding(),
            Text(
              widget.email,
              style: theme.textTheme.labelLarge!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ).defaultPadding(),
            const GapV(16),
            Text(
              "If the email is correct, click the button below to send an OTP and verify your account.",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ).defaultPadding(),
            const GapV(16),
            const Spacer(),
            ButtonPrimary(
              text: "Send OTP",
              onPressed: () {
                sendOtpCubit.resendTheOtp(widget.email);
              },
            ),
            const GapV(16),
          ],
        ),
      ),
    );
  }
}
