import 'package:flutter/material.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/paddings.dart';

class LineSeperator extends StatelessWidget {
  const LineSeperator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.greyDark,
      height: 0.5,
    ).pSymmetric(horizontal: 2);
  }
}
