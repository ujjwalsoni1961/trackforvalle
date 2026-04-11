import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/validator.dart';
import 'package:track/src/core/ui/widgets/form_manager.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/register_cubit.dart';
import 'package:track/src/features/authentication/presentation/register/cubit/register_state.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';
import 'package:track/src/features/authentication/presentation/register/widgets/welcome_register_banner.dart';
import 'package:track/src/features/authentication/presentation/verifyEmail/cubit/verify_email_otp_timer_cubit.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({super.key});

  @override
  State<RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  late RegisterCubit registerCubit = context.read<RegisterCubit>();
  late VerifyEmailOtpTimerCubit verifyEmailOTPTimerCubit = context
      .read<VerifyEmailOtpTimerCubit>();
  late ThemeData theme = Theme.of(context);

  final TextEditingController emailController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController phoneNumController = TextEditingController();
  final TextEditingController organizationController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();

  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusScopeNode focusScopeNode = FocusScopeNode();

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      title: "Create Account",
      hideKeyboardOnTap: true,
      body: BlocConsumer<RegisterCubit, RegisterState>(
        listener: (context, state) {
          // Logic for the Registering state

          if (state is Registering) {
            LoadingAnimation.show(context);
          }
          if (state is RegisterSuccess) {
            context.pop();
            context.push(Routes.tabs);
          }
          if (state is RegisterFailed) {
            context.pop();
            context.errorBar(state.errorMessage);
          }
        },
        builder: (context, state) {
          return Scrollbar(
            thumbVisibility: true,
            thickness: 4,
            interactive: true,
            radius: const Radius.circular(8),
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const RegisterBanner(),
                  const Gap(16),
                  Column(
                    children: [
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter an email';
                          } else if (!Validator.validateEmail(value)) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Email',
                          prefixIcon: Transform.scale(
                            scale: 0.4,
                            child: context.icon(
                              AppIcons.email,
                              color: theme.iconTheme.color,
                            ),
                          ),
                        ),
                      ).defaultPadding(),
                      TextFormField(
                        controller: firstNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a first name';
                          } else if (!Validator.validateName(value)) {
                            return 'Please enter a valid first name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'First Name',
                          prefixIcon: Transform.scale(
                            scale: 0.4,
                            child: context.icon(
                              AppIcons.user,
                              color: theme.iconTheme.color,
                            ),
                          ),
                        ),
                      ).defaultPadding(),
                      TextFormField(
                        controller: lastNameController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a last name';
                          } else if (!Validator.validateName(value)) {
                            return 'Please enter a valid last name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Last Name',
                          prefixIcon: Transform.scale(
                            scale: 0.4,
                            child: context.icon(
                              AppIcons.user,
                              color: theme.iconTheme.color,
                            ),
                          ),
                        ),
                      ).defaultPadding(),
                      TextFormField(
                        controller: phoneNumController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a Phone Number';
                          } else if (!Validator.validatePhone(value)) {
                            return 'Please enter a valid Phone Number';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          prefixIcon: Transform.scale(
                            scale: 0.4,
                            child: context.icon(
                              AppIcons.edit,
                              color: theme.iconTheme.color,
                            ),
                          ),
                        ),
                      ).defaultPadding(),
                      TextFormField(
                        controller: organizationController,
                        keyboardType: TextInputType.name,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a organization name';
                          } else if (!Validator.validateName(value)) {
                            return 'Please enter a valid organization name';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Organization Name',
                          prefixIcon: Transform.scale(
                            scale: 0.4,
                            child: context.icon(
                              AppIcons.book,
                              color: theme.iconTheme.color,
                            ),
                          ),
                        ),
                      ).defaultPadding(),
                      TextFormField(
                        controller: passwordController,
                        obscureText: state is PasswordVisibilityChanged
                            ? !state.isPasswordVisible
                            : true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Please enter a password';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Password',
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
                              state is PasswordVisibilityChanged
                                  ? state.isPasswordVisible
                                        ? AppIcons.visiblityOff
                                        : AppIcons.visiblity
                                  : AppIcons.visiblity,
                              size: 18,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {
                              registerCubit.togglePasswordVisibility();
                            },
                          ),
                        ),
                      ).defaultPadding(),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: state is ConfirmPasswordVisibilityChanged
                            ? !state.isConfirmPasswordVisible
                            : true,
                        keyboardType: TextInputType.visiblePassword,
                        validator: (value) {
                          if (value!.isEmpty) {
                            return 'Confirm your password';
                          } else if (value != passwordController.text) {
                            return 'Passwords do not match';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          labelText: 'Confirm Password',
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
                              state is ConfirmPasswordVisibilityChanged
                                  ? state.isConfirmPasswordVisible
                                        ? AppIcons.visiblityOff
                                        : AppIcons.visiblity
                                  : AppIcons.visiblity,
                              size: 18,
                              color: theme.iconTheme.color,
                            ),
                            onPressed: () {
                              registerCubit.toggleConfirmPasswordVisibility();
                            },
                          ),
                        ),
                      ).defaultPadding(),
                    ],
                  ),
                  const Gap(16),
                  ButtonPrimary(
                    text: 'Register',
                    onPressed: () {
                      if (!formKey.currentState!.validate()) {
                        return;
                      }
                      focusScopeNode.unfocus();
                      registerCubit.register(
                        firstName: firstNameController.text.trim(),
                        lastName: lastNameController.text.trim(),
                        phoneNum: phoneNumController.text.trim(),
                        orgName: organizationController.text.trim(),
                        email: emailController.text.trim(),
                        password: passwordController.text.trim(),
                      );
                      FocusScope.of(context).unfocus();
                    },
                  ),
                  const Gap(16),
                ],
              ).makeItForm(formKey, focusScopeNode),
            ),
          );
        },
      ),
    );
  }
}
