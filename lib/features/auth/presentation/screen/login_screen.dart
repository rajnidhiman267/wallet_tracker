import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/constants/image_contants.dart';
import 'package:tracker_app/core/utils/helper_utils.dart';
import 'package:tracker_app/core/utils/validation_utils.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/widgets/async_call_wrapper_widget.dart';
import 'package:tracker_app/core/widgets/label_with_text_form_field.dart';
import 'package:tracker_app/core/widgets/outline_button_with_icon_widget.dart';
import 'package:tracker_app/core/widgets/primary_button.dart';
import 'package:tracker_app/features/auth/presentation/bloc/login_cubit.dart';
import 'package:tracker_app/features/auth/presentation/bloc/login_state.dart';
 

class LoginScrren extends StatefulWidget {
  const LoginScrren({super.key});

  @override
  State<LoginScrren> createState() => _LoginScrrenState();
}

class _LoginScrrenState extends State<LoginScrren> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late GlobalKey<FormState> loginKey;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loginKey = GlobalKey<FormState>();
  }

  

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state.isSuccess == true) {
          HelperUtils.showCustomToast(toastMsg: "Login successfully!");
          context.goNamed(AppRouteName.home);
        }
        if (state.errorMessage != null) {
          HelperUtils.showCustomToast(
            toastMsg: state.errorMessage,
            isError: true,
          );
        }
      },
      builder: (context, state) {
        return ModalProgressHUD(
          inAsyncCall: state.isLoading,
          child: SafeArea(
            top: false,
            child: Scaffold(
              backgroundColor: Colors.white,
              body: Padding(
                padding: EdgeInsetsGeometry.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      spacing: 36,
                      mainAxisAlignment: .center,
                      crossAxisAlignment: .start,
                      children: [
                        Column(
                          spacing: 8,
                          crossAxisAlignment: .start,
                          children: [
                            Text(
                              'Welcome back',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            Text(
                              "Sign in to continue tracking your expenses",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        Form(
                          key: loginKey,
                          child: Column(
                            spacing: 12,
                            children: [
                              LabelWithTextFormField(
                                label: "Email",
                                hintText: "Enter your email",
                                controller: emailController,
                                validator: AppValidator().email,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.emailAddress,
                               
                              ),
                              LabelWithTextFormField(
                                label: "Password",
                                hintText: "Enter your password",
                                isPasswordField: true,
                                controller: passwordController,
                                validator: AppValidator().password,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ],
                          ),
                        ),

                        Center(
                          child: Column(
                            spacing: 16,

                            children: [
                              PrimaryOutlineButton(
                                title: 'Login',
                                onPressed: () {
                                  if (loginKey.currentState!.validate()) {
                                    FocusScope.of(context).unfocus();
                                    context.read<LoginCubit>().login(
                                      email: emailController.text,
                                      password: passwordController.text,
                                    );
                                  }
                                },
                              ),
                              Text(
                                "or continue with",
                                style: Theme.of(context).textTheme.bodyMedium,
                              ),

                              OutlineButtonWithIconWidget(
                                svgImage: googleSvg,
                                label: 'Sign in with Google',
                                onTap: () {},
                              ),
                              InkWell(
                                onTap: () =>
                                    context.pushNamed(AppRouteName.signup),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: "Sign up",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium
                                            ?.copyWith(
                                              color: AppColors.linkColor,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
