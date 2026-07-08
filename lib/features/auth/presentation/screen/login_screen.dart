import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:tracker_app/core/constants/image_contants.dart';
import 'package:tracker_app/core/routes/app_route_name.dart';
import 'package:tracker_app/core/theme/app_color.dart';
import 'package:tracker_app/core/utils/helper_utils.dart';
import 'package:tracker_app/core/utils/validation_utils.dart';
import 'package:tracker_app/core/widgets/label_with_text_form_field.dart';
import 'package:tracker_app/core/widgets/outline_button_with_icon_widget.dart';
import 'package:tracker_app/core/widgets/primary_button.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_cubit.dart';
import 'package:tracker_app/features/auth/presentation/bloc/auth_state.dart';

class LoginScrren extends StatefulWidget {
  const LoginScrren({super.key});

  @override
  State<LoginScrren> createState() => _LoginScrrenState();
}

class _LoginScrrenState extends State<LoginScrren> with TickerProviderStateMixin {
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late GlobalKey<FormState> loginKey;

  late AnimationController _animCtrl;
  late Animation<double> _logoScale;
  late Animation<double> _formFade;
  late Animation<Offset> _formSlide;

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    loginKey = GlobalKey<FormState>();

    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 800));
    _logoScale = Tween<double>(begin: 0.6, end: 1.0).animate(
        CurvedAnimation(parent: _animCtrl, curve: const Interval(0, 0.5, curve: Curves.elasticOut)));
    _formFade = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _animCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeIn)));
    _formSlide = Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
        CurvedAnimation(parent: _animCtrl, curve: const Interval(0.3, 1.0, curve: Curves.easeOut)));

    _animCtrl.forward();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthCubit>().checkBiometricAvailability();
    });
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state.isSuccess) {
          HelperUtils.showCustomToast(toastMsg: 'Welcome back!');
          context.goNamed(AppRouteName.home);
        }
        if (state.errorMessage != null) {
          HelperUtils.showCustomToast(toastMsg: state.errorMessage, isError: true);
        }
      },
      builder: (context, state) {
        return Scaffold(
          body: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                height: MediaQuery.of(context).size.height - MediaQuery.of(context).padding.top,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo / Brand area
                    ScaleTransition(
                      scale: _logoScale,
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [AppColors.gradientStart, AppColors.gradientEnd],
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Icon(Icons.account_balance_wallet_rounded,
                                color: Colors.white, size: 36),
                          ),
                          const SizedBox(height: 16),
                          Text('Expense Tracker',
                              style: theme.textTheme.headlineSmall),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),

                    // Form
                    FadeTransition(
                      opacity: _formFade,
                      child: SlideTransition(
                        position: _formSlide,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Welcome back', style: theme.textTheme.headlineMedium),
                            const SizedBox(height: 4),
                            Text('Sign in to continue tracking your expenses',
                                style: theme.textTheme.bodyMedium),
                            const SizedBox(height: 28),
                            Form(
                              key: loginKey,
                              child: Column(
                                children: [
                                  LabelWithTextFormField(
                                    label: 'Email',
                                    hintText: 'Enter your email',
                                    controller: emailController,
                                    validator: AppValidator().email,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.emailAddress,
                                  ),
                                  const SizedBox(height: 12),
                                  LabelWithTextFormField(
                                    label: 'Password',
                                    hintText: 'Enter your password',
                                    isPasswordField: true,
                                    controller: passwordController,
                                    validator: AppValidator().password,
                                    autovalidateMode: AutovalidateMode.onUserInteraction,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: PrimaryOutlineButton(
                                title: 'Sign In',
                                isLoading: state.isLoading,
                                onPressed: state.isLoading
                                    ? null
                                    : () {
                                        if (loginKey.currentState!.validate()) {
                                          FocusScope.of(context).unfocus();
                                          context.read<AuthCubit>().login(
                                                email: emailController.text,
                                                password: passwordController.text,
                                              );
                                        }
                                      },
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              children: [
                                const Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('or', style: theme.textTheme.bodySmall),
                                ),
                                const Expanded(child: Divider()),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlineButtonWithIconWidget(
                              svgImage: googleSvg,
                              label: 'Continue with Google',
                              onTap: state.isLoading
                                  ? () {}
                                  : () => context.read<AuthCubit>().signInWithGoogleRequested(),
                            ),
                            // Biometric button (shown only when available & user has a session)
                            if (state.isBiometricAvailable) ...[
                              const SizedBox(height: 12),
                              SizedBox(
                                width: MediaQuery.of(context).size.width / 1.5,
                                child: OutlinedButton.icon(
                                  onPressed: () =>
                                      context.read<AuthCubit>().loginWithBiometric(),
                                  icon: const Icon(Icons.fingerprint_rounded),
                                  label: const Text('Use Biometrics'),
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16)),
                                    side: const BorderSide(color: AppColors.borderColor),
                                  ),
                                ),
                              ),
                            ],
                            const SizedBox(height: 20),
                            Center(
                              child: GestureDetector(
                                onTap: () => context.pushNamed(AppRouteName.signup),
                                child: RichText(
                                  text: TextSpan(
                                    text: "Don't have an account? ",
                                    style: theme.textTheme.bodyMedium,
                                    children: [
                                      TextSpan(
                                        text: 'Sign up',
                                        style: theme.textTheme.bodyMedium?.copyWith(
                                          color: AppColors.linkColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}