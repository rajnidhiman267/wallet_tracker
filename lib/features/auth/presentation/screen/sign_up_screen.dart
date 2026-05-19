import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/constants/image_contants.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/utils/helper_utils.dart';
import 'package:tracker_app/core/utils/validation_utils.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/widgets/async_call_wrapper_widget.dart';
import 'package:tracker_app/core/widgets/label_with_text_form_field.dart';
import 'package:tracker_app/core/widgets/outline_button_with_icon_widget.dart';
import 'package:tracker_app/core/widgets/primary_button.dart';
import 'package:tracker_app/features/auth/presentation/bloc/sign_up_cubit.dart';
import 'package:tracker_app/features/auth/presentation/bloc/sign_up_state.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  late GlobalKey<FormState> signUpKey;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
    signUpKey = GlobalKey<FormState>();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<SignUpCubit, SignUpState>(
      listener: (context, state) {
        if (state.isSuccess == true) {
          HelperUtils.showCustomToast(toastMsg: "Sign up successfully!");
          context.goNamed(AppRouteName.profileSetup);
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
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: SingleChildScrollView(
                  child: SizedBox(
                    height: MediaQuery.of(context).size.height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      spacing: 36,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Sign Up',
                              style: Theme.of(context).textTheme.headlineMedium,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              "Please sign up to continue",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),

                        Form(
                          key: signUpKey,
                          child: Column(
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

                              const SizedBox(height: 12),

                              LabelWithTextFormField(
                                label: "Password",
                                hintText: "Enter your password",
                                isPasswordField: true,
                                controller: passwordController,
                                validator: AppValidator().password,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),

                              const SizedBox(height: 12),

                              LabelWithTextFormField(
                                label: "Confirm Password",
                                hintText: "Enter your confirm password",
                                isPasswordField: true,
                                controller: confirmPasswordController,
                                validator: (value) =>
                                    AppValidator().confirmPassword(
                                      value: value,
                                      originalPassword: passwordController.text,
                                    ),
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                              ),
                            ],
                          ),
                        ),

                        Column(
                          spacing: 12,
                          children: [
                            PrimaryOutlineButton(
                              title: state.isLoading == true
                                  ? "Loading..."
                                  : 'Sign Up',
                              onPressed: () {
                                if (signUpKey.currentState!.validate()) {
                                  FocusScope.of(context).unfocus();
                                  context.read<SignUpCubit>().signUp(
                                    email: emailController.text,
                                    password: confirmPasswordController.text,
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
                              label: 'Sign up with Google',
                              onTap: () {},
                            ),
                            InkWell(
                              onTap: () => context.pop(),
                              child: RichText(
                                text: TextSpan(
                                  text: "Already have an account? ",
                                  style: Theme.of(context).textTheme.bodyMedium,
                                  children: [
                                    TextSpan(
                                      text: "Login",
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
