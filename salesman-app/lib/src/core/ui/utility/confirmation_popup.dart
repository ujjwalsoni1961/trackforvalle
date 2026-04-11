import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';

class ConfirmationPopup {
  static void show({
    required BuildContext context,
    required String title,
    required String content,
    String? buttonText,
    required Function onDone,
  }) {
    final ThemeData theme = Theme.of(context);
    showGeneralDialog(
      context: context,
      barrierDismissible: false,
      barrierLabel: '',
      pageBuilder: (context, animation, secondaryAnimation) => const SizedBox(),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        return ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          // Elastic animation
          child: AlertDialog(
            backgroundColor: AppColors.transparent,
            surfaceTintColor: theme.colorScheme.surface,
            contentPadding: EdgeInsets.zero,
            content: Card(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const GapV(16),
                  SizedBox(width: MediaQuery.of(context).size.width),
                  Text(
                    title,
                    style: theme.textTheme.titleLarge!.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const GapV(8),
                  Text(
                    content,
                    style: theme.textTheme.titleSmall!.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const GapV(16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            context.pop();
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            'Cancel',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ).pSymmetric(horizontal: 8, vertical: 4),
                        ),
                        const GapH(16),
                        InkWell(
                          borderRadius: BorderRadius.circular(24),
                          onTap: () {
                            onDone();
                            context.pop();
                            FocusScope.of(context).unfocus();
                          },
                          child: Text(
                            buttonText ?? 'Confirm',
                            style: theme.textTheme.bodyMedium!.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.bold,
                            ),
                          ).pSymmetric(horizontal: 8, vertical: 4),
                        ),
                      ],
                    ),
                  ),
                  const GapV(16),
                ],
              ).pSymmetric(horizontal: 16),
            ),
          ),
        );
      },
      transitionDuration: const Duration(
        milliseconds: 100,
      ), // Duration of the entrance animation
    );
  }
}

extension ConfirmationPopupExtension on BuildContext {
  void confirm({
    String? buttonText,
    required String title,
    required String content,
    required Function onDone,
  }) {
    ConfirmationPopup.show(
      context: this,
      title: title,
      buttonText: buttonText,
      content: content,
      onDone: () => onDone(),
    );
  }
}
