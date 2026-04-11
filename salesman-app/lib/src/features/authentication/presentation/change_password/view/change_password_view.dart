import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/widgets/form_manager.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/authentication/presentation/change_password/cubit/change_password_cubit.dart';

class ChangePasswordView extends StatefulWidget {
  const ChangePasswordView({super.key});

  @override
  State<ChangePasswordView> createState() => _ChangePasswordViewState();
}

class _ChangePasswordViewState extends State<ChangePasswordView> {
  late ChangePasswordCubit changePasswordCubit = context
      .read<ChangePasswordCubit>();
  late ThemeData theme = Theme.of(context);
  final TextEditingController oldPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  final focusScopeNode = FocusScopeNode();

  @override
  void dispose() {
    changePasswordCubit.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      hideKeyboardOnTap: true,
      title: "Change Password",
      body: BlocConsumer<ChangePasswordCubit, ChangePasswordState>(
        listener: (context, state) {
          if (state is ChangingPassword) {
            LoadingAnimation.show(context);
          }
          if (state is ChangePasswordFailed) {
            context.pop();
            context.errorBar(state.errorMessage);
          }
          if (state is ChangePasswordSuccess) {
            context.pop();
            oldPasswordController.clear();
            newPasswordController.clear();
            confirmPasswordController.clear();
            context.successBar("Password Changed!");
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const GapV(16),
                Text(
                  "For a fresh start and enhanced security, reset your password here.",
                  style: theme.textTheme.bodyLarge!.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ).defaultPadding(),
                const GapV(16),
                Column(
                  children: [
                    TextFormField(
                      controller: oldPasswordController,
                      obscureText: state is OldPasswordVisibliityChanged
                          ? !state.isVisible
                          : !changePasswordCubit.isOldPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Please enter old password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Old Password',
                        prefixIcon: Transform.scale(
                          scale: 0.4,
                          child: context.icon(
                            AppIcons.password,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        suffixIcon: IconButton(
                          splashColor: AppColors.transparent,
                          icon: context.icon(
                            state is OldPasswordVisibliityChanged
                                ? state.isVisible
                                      ? AppIcons.visiblityOff
                                      : AppIcons.visiblity
                                : AppIcons.visiblity,
                            size: 18,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () {
                            changePasswordCubit.toggleOldPasswordVisibility();
                          },
                        ),
                      ),
                    ).defaultPadding(),
                    TextFormField(
                      controller: newPasswordController,
                      obscureText: state is NewPasswordVisibliityChanged
                          ? !state.isVisible
                          : !changePasswordCubit.isNewPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter new password';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'New Password',
                        prefixIcon: Transform.scale(
                          scale: 0.4,
                          child: context.icon(
                            AppIcons.password,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        suffixIcon: IconButton(
                          splashColor: AppColors.transparent,
                          icon: context.icon(
                            state is NewPasswordVisibliityChanged
                                ? state.isVisible
                                      ? AppIcons.visiblityOff
                                      : AppIcons.visiblity
                                : AppIcons.visiblity,
                            size: 18,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () {
                            changePasswordCubit.toggleNewPasswordVisibility();
                          },
                        ),
                      ),
                    ).defaultPadding(),
                    TextFormField(
                      controller: confirmPasswordController,
                      obscureText: state is ConfirmPasswordVisiblityChanged
                          ? !state.isVisible
                          : !changePasswordCubit.isConfirmPasswordVisible,
                      keyboardType: TextInputType.visiblePassword,
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Confirm your password';
                        } else if (value != newPasswordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                        labelText: 'Confirm New Password',
                        prefixIcon: Transform.scale(
                          scale: 0.4,
                          child: context.icon(
                            AppIcons.password,
                            color: theme.iconTheme.color,
                          ),
                        ),
                        suffixIcon: IconButton(
                          splashColor: AppColors.transparent,
                          icon: context.icon(
                            state is ConfirmPasswordVisiblityChanged
                                ? state.isVisible
                                      ? AppIcons.visiblityOff
                                      : AppIcons.visiblity
                                : AppIcons.visiblity,
                            size: 18,
                            color: theme.iconTheme.color,
                          ),
                          onPressed: () {
                            changePasswordCubit
                                .toggleConfirmPasswordVisibility();
                          },
                        ),
                      ),
                    ).defaultPadding(),
                  ],
                ).makeItForm(formKey, focusScopeNode),
                const GapV(32),
                ButtonPrimary(
                  text: 'Change Password',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    focusScopeNode.unfocus();
                    changePasswordCubit.changedThePassword(
                      oldPasswordController.text.trim(),
                      newPasswordController.text.trim(),
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
