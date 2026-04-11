import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_cubit.dart';

class VerifyEmailOtpTextFeilds extends StatefulWidget {
  final TextEditingController controller;
  const VerifyEmailOtpTextFeilds({super.key, required this.controller});

  @override
  State<VerifyEmailOtpTextFeilds> createState() =>
      _VerifyEmailOtpTextFeildsState();
}

class _VerifyEmailOtpTextFeildsState extends State<VerifyEmailOtpTextFeilds> {
  late VerifyEmailCubit verifyEmailCubit = context.read<VerifyEmailCubit>();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return PinCodeTextField(
      appContext: context,
      pastedTextStyle: TextStyle(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      textStyle: theme.textTheme.bodyMedium,
      length: 6,
      blinkWhenObscuring: true,
      animationType: AnimationType.fade,
      validator: (v) {
        if (v!.length < 6) {
          return "Enter Valid Otp";
        } else {
          return null;
        }
      },
      backgroundColor: theme.colorScheme.surface,
      pinTheme: PinTheme(
        shape: PinCodeFieldShape.box,
        borderRadius: BorderRadius.circular(8),
        fieldHeight: 42,
        fieldWidth: 36,
        activeFillColor: theme.colorScheme.surface,
        inactiveFillColor: theme.colorScheme.surface,
        errorBorderColor: theme.colorScheme.surface,
        inactiveColor: theme.colorScheme.tertiary,
        selectedFillColor: theme.colorScheme.surface,
      ),
      cursorColor: theme.colorScheme.surface,
      animationDuration: const Duration(milliseconds: 300),
      enableActiveFill: true,
      errorAnimationController: null,
      controller: null,
      keyboardType: TextInputType.number,
      boxShadows: [
        BoxShadow(
          offset: const Offset(0, 5),
          color: theme.colorScheme.surface,
          blurRadius: 24,
        ),
      ],
      onChanged: (otp) {
        widget.controller.text = otp;
      },
      onCompleted: (otp) {
        widget.controller.text = otp;
      },
    ).pSymmetric(horizontal: 36);
  }
}
