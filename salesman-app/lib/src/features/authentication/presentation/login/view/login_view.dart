import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:track/src/core/ui/res/app_colors.dart';
import 'package:track/src/core/ui/res/app_icons.dart';
import 'package:track/src/core/ui/routes/routes.dart';
import 'package:track/src/core/ui/utility/loading_animation.dart';
import 'package:track/src/core/ui/utility/toast.dart';
import 'package:track/src/core/ui/utility/validator.dart';
import 'package:track/src/core/ui/utility/visible_if.dart';
import 'package:track/src/core/ui/widgets/form_manager.dart';
import 'package:track/src/features/authentication/presentation/login/cubit/login_cubit.dart';
import 'package:track/src/features/authentication/presentation/login/widgets/forgot_password_widget.dart';
import 'package:track/src/features/authentication/presentation/login/widgets/welcome_login_banner.dart';
import 'package:track/src/core/ui/widgets/button_primary.dart';
import 'package:track/src/core/ui/utility/paddings.dart';
import 'package:track/src/core/ui/widgets/gap.dart';
import 'package:track/src/core/ui/widgets/my_scaffold.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  late LoginCubit loginCubit = context.read<LoginCubit>();
  late ThemeData theme = Theme.of(context);
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  FocusScopeNode focusNode = FocusScopeNode();

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      hideKeyboardOnTap: true,
      title: "Login",
      body: BlocConsumer<LoginCubit, LoginState>(
        listener: (context, state) {
          if (state is LoggingIn) {
            LoadingAnimation.show(context);
          }
          if (state is LoginSuccess) {
            context.pop();
            // double check if email is verified
            context.go(Routes.splash);
          }
          if (state is LoginFailed) {
            context.pop();
            context.errorBar(state.errorMessage);
          }
        },
        builder: (context, state) {
          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: [
                const WelcomeLoginBanner(),
                const Gap(16),
                TextFormField(
                  keyboardType: TextInputType.emailAddress,
                  controller: emailController,
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
                  obscureText: state is PasswordVisibilityChanged
                      ? !state.isPasswordVisible
                      : true,
                  keyboardType: TextInputType.visiblePassword,
                  controller: passwordController,
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
                        loginCubit.togglePasswordVisibility();
                      },
                    ),
                  ),
                ).defaultPadding(),
                const ForgotPasswordWidget(),
                const Gap(16),
                ButtonPrimary(
                  text: 'Login',
                  onPressed: () {
                    if (!formKey.currentState!.validate()) {
                      return;
                    }
                    focusNode.unfocus();
                    loginCubit.login(
                      emailController.text.trim(),
                      passwordController.text.trim(),
                    );
                  },
                ).visibleIf(true),
                const GapV(24),
              ],
            ).makeItForm(formKey, focusNode),
          );
        },
      ),
    );
  }
}
