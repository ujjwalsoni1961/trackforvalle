import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/features/authentication/presentation/firstPage/cubit/first_page_cubit.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyCheckBox extends StatefulWidget {
  const PrivacyPolicyCheckBox({super.key});

  @override
  State<PrivacyPolicyCheckBox> createState() => _PrivacyPolicyCheckBoxState();
}

class _PrivacyPolicyCheckBoxState extends State<PrivacyPolicyCheckBox> {
  late FirstPageCubit firstPageCubit = context.read<FirstPageCubit>();
  late ThemeData theme = Theme.of(context);
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FirstPageCubit, FirstPageState>(
      builder: (context, state) {
        return Row(
          children: [
            Checkbox(
              value: state is TermsAndConditionToggled
                  ? state.isChecked
                  : firstPageCubit.isTermsAndPrivacyChecked,
              onChanged: (value) {
                firstPageCubit.toggleCheckBox();
              },
            ),
            Expanded(
              child: Wrap(
                children: [
                  Text(
                    "By Checking this, you agree to our ",
                    textAlign: TextAlign.justify,
                    style: theme.textTheme.labelMedium,
                  ),
                  InkWell(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse(
                          'https://www.google.com/terms-and-conditions/',
                        ),
                      );
                    },
                    child: Text(
                      "Terms & Conditions",
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.greyDark,
                      ),
                    ),
                  ),
                  Text(
                    " and ",
                    textAlign: TextAlign.justify,
                    style: theme.textTheme.labelMedium,
                  ),
                  InkWell(
                    onTap: () async {
                      await launchUrl(
                        Uri.parse('https://www.google.com/privacy-policy/'),
                      );
                    },
                    child: Text(
                      "Privacy Policy.",
                      textAlign: TextAlign.justify,
                      style: theme.textTheme.labelMedium!.copyWith(
                        fontWeight: FontWeight.bold,
                        decoration: TextDecoration.underline,
                        decorationColor: AppColors.greyDark,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    ).pSymmetric(horizontal: 8).pRight(20);
  }
}
