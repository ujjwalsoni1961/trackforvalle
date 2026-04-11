import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_assets.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/visible_if.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
// import 'package:track/src/core/ui/widgets/text_logo.dart';
import 'package:track/src/features/authentication/presentation/firstPage/cubit/first_page_cubit.dart';
import 'package:track/src/features/authentication/presentation/firstPage/widgets/first_page_slide.dart';
import 'package:track/src/features/authentication/presentation/firstPage/widgets/terms_check.dart';

class FirstPageView extends StatefulWidget {
  const FirstPageView({super.key});

  @override
  State<FirstPageView> createState() => _FirstPageViewState();
}

class _FirstPageViewState extends State<FirstPageView> {
  late FirstPageCubit firstPageCubit = context.read<FirstPageCubit>();
  late ThemeData theme = Theme.of(context);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      appBar: AppBar(),
      body: BlocConsumer<FirstPageCubit, FirstPageState>(
        listener: (context, state) {
          if (state is GoogleSigninInProgress) {
            LoadingAnimation.show(context);
          }
          if (state is GoogleSigninSuccess) {
            context.pop();
            context.go(Routes.splash);
          }
          if (state is GoogleSigninFailure) {
            if (!state.errorMessage.contains("terms & condition")) {
              context.pop();
            }
            context.errorBar(state.errorMessage);
          }
        },
        builder: (context, state) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: [
              const Expanded(
                child: FirstPageSlideWidget(
                  text:
                      "Welcome – your smart companion for managing visits, navigating routes, and boosting sales productivity on the go.",
                  imagePath: AppAssets.firstPageSlide2,
                ),
              ),
              const PrivacyPolicyCheckBox(),
              ButtonPrimary(
                text: 'Continue with Email',
                suffixIcon: context.icon(
                  AppIcons.email,
                  size: 18,
                  color: AppColors.bgMain,
                ),
                onPressed: () {
                  if (state is GoogleSigninInProgress) {
                    return;
                  }
                  if (!firstPageCubit.isTermsAndPrivacyChecked) {
                    context.errorBar(
                      "Please agree to terms & condition and privacy policy.",
                    );
                    return;
                  }
                  context.push(Routes.login);
                },
              ).visibleIf(true),
              const GapV(48),
            ],
          );
        },
      ),
    );
  }
}
