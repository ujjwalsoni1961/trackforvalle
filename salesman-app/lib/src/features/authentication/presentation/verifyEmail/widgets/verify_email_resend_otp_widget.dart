import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/send_otp_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_cubit.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_otp_timer_cubit.dart';

class VerifyEmailResendOTPWidget extends StatefulWidget {
  final String email;
  const VerifyEmailResendOTPWidget({super.key, required this.email});

  @override
  State<VerifyEmailResendOTPWidget> createState() =>
      _VerifyEmailResendOTPWidgetState();
}

class _VerifyEmailResendOTPWidgetState
    extends State<VerifyEmailResendOTPWidget> {
  late VerifyEmailCubit verifyEmailCubit = context.read<VerifyEmailCubit>();
  late VerifyEmailOtpTimerCubit verifyEmailOtpTimerCubit = context
      .read<VerifyEmailOtpTimerCubit>();
  late SendOtpCubit sendOTPCubit = context.read<SendOtpCubit>();
  late ThemeData theme = Theme.of(context);

  @override
  Widget build(BuildContext context) {
    return BlocListener<SendOtpCubit, SendOtpState>(
      listener: (context, sendOTPState) {
        if (sendOTPState is OTPSent) {
          context.pop();
          verifyEmailOtpTimerCubit.startTimer();
        }
        if (sendOTPState is SendingOTP) {
          LoadingAnimation.show(context);
        }
      },
      child: BlocBuilder<VerifyEmailOtpTimerCubit, VerifyEmailOtpTimerState>(
        builder: (context, state) {
          return Row(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  if (state is! TimerTicking) {
                    sendOTPCubit.resendTheOtp(widget.email);
                  }
                },
                child: Text(
                  state is! TimerTicking
                      ? "Resend OTP?"
                      : "Resend OTP in ${verifyEmailCubit.formatDuration(state.seconds)}",
                  style: theme.textTheme.labelMedium!.copyWith(
                    color: state is! TimerTicking
                        ? theme.colorScheme.primary
                        : theme.colorScheme.tertiary,
                    fontWeight: FontWeight.bold,
                  ),
                ).pSymmetric(vertical: 2, horizontal: 4),
              ),
            ],
          ).pSymmetric(horizontal: 36, vertical: 4);
        },
      ),
    );
  }
}
