import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/add_shadow.dart';
import 'package:track/src/core/ui/utility/paddings.dart';

class ButtonPrimary extends StatefulWidget {
  final String text;
  final Function onPressed;
  final Widget? suffixIcon;
  const ButtonPrimary({
    super.key,
    required this.text,
    required this.onPressed,
    this.suffixIcon,
  });

  @override
  State<ButtonPrimary> createState() => _ButtonPrimaryState();
}

class _ButtonPrimaryState extends State<ButtonPrimary> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.center,
      child: ElevatedButton(
        onPressed: () {
          HapticFeedback.selectionClick();
          widget.onPressed();
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (widget.suffixIcon != null) widget.suffixIcon!.pOnly(right: 8),
            Text(
              widget.text,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ).pSymmetric(vertical: 2),
      ).addShadow().defaultPadding(),
    );
  }
}
