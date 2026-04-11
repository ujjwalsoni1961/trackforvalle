import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/utility/paddings.dart';

class BackWidget extends StatefulWidget {
  const BackWidget({super.key});

  @override
  State<BackWidget> createState() => _BackWidgetState();
}

class _BackWidgetState extends State<BackWidget> {
  late ThemeData theme = Theme.of(context);

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: () {
        context.pop();
      },
      iconSize: 18,
      splashColor: AppColors.transparent,
      icon: context.icon(AppIcons.back),
    ).pAll(8);
  }
}
