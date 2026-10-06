import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/utils/app_scaler.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_checkbox.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/app_toast.dart';
import 'forgot_password_sheet.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      // =========================================================
      // IOU DARK PURPLE THEME
      // =========================================================

      backgroundColor: AppColors.background,

      resizeToAvoidBottomInset: false,

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),

        child: SafeArea(
          child: Stack(
            children: [
              // =======================================================
              // TOP RIGHT PURPLE GLOW
              // =======================================================

              Positioned(
                top: -s.h(120),
                right: -s.w(130),
                child: Container(
                  width: s.w(280),
                  height: s.w(280),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.16,
                        ),
                        AppColors.primary.withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =======================================================
              // BOTTOM LEFT PURPLE GLOW
              // =======================================================

              Positioned(
                bottom: -s.h(120),
                left: -s.w(150),
                child: Container(
                  width: s.w(300),
                  height: s.w(300),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        AppColors.accent.withValues(
                          alpha: 0.12,
                        ),
                        AppColors.accent.withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // =======================================================
              // BACKGROUND MONEY TRANSFER IMAGE
              // =======================================================

              Positioned(
                left: 0,
                right: 0,
                top: 155,
                child: Opacity(
                  opacity: 0.18,
                  child: SizedBox(
                    width: s.w(411),
                    height: s.h(428),
                    child: Image.asset(
                      AppAssets.moneyTransfer,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              ),

              // =======================================================
              // BACK ARROW
              // =======================================================

              Positioned(
                left: s.w(16),
                top: s.h(16),
                child: GestureDetector(
                  onTap: () {
                    context.pop();
                  },
                  child: Opacity(
                    opacity: 0.85,
                    child: SizedBox(
                      width: s.w(59),
                      height: s.h(55),
                      child: Image.asset(
                        AppAssets.backArrow,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              ),

              // =======================================================
              // WELCOME
              // =======================================================

              Positioned(
                left: s.w(32),
                top: s.h(104),
                child: SizedBox(
                  width: s.w(297),
                  height: s.h(184),
                  child: Text(
                    "Welcome",
                    style: AppTextStyles.welcomeText(
                      s.sp(48),
                    ),
                  ),
                ),
              ),

              // =======================================================
              // BACK!
              // =======================================================

              Positioned(
                left: s.w(32),
                top: s.h(155),
                child: Text(
                  "Back!",
                  style: AppTextStyles.welcomeBackText(
                    s.sp(48),
                  ),
                ),
              ),

              // =======================================================
              // EMAIL TEXT FIELD
              // =======================================================

              Positioned(
                left: s.w(20),
                top: s.h(306),
                child: SizedBox(
                  width: s.w(358),
                  child: AppTextField(
                    controller: emailController,
                    hintText: "Email Address",
                    prefixIcon: const AppIcon(
                      AppAssets.emailIcon,
                    ),
                  ),
                ),
              ),

              // =======================================================
              // PASSWORD TEXT FIELD
              // =======================================================

              Positioned(
                left: s.w(18),
                top: s.h(378),
                child: SizedBox(
                  width: s.w(362),
                  child: AppTextField(
                    controller: passwordController,
                    hintText: "Password",
                    obscureText: true,
                    isPassword: true,
                    prefixIcon: const AppIcon(
                      AppAssets.lock,
                      padding: EdgeInsets.fromLTRB(
                        17,
                        14,
                        10,
                        14,
                      ),
                    ),
                  ),
                ),
              ),

              // =======================================================
              // FORGOT PASSWORD
              // =======================================================

              Positioned(
                right: s.w(20),
                top: s.h(453),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      backgroundColor: AppColors.background,
                      builder: (_) =>
                      const ForgotPasswordSheet(),
                    );
                  },
                  child: Text(
                    "Forgot Password?",
                    style: AppTextStyles.buttonText(
                      16,
                    ),
                  ),
                ),
              ),

              // =======================================================
              // REMEMBER ME
              // =======================================================

              Positioned(
                left: s.w(26),
                top: s.h(453),
                child: Row(
                  children: [
                    AppCheckbox(
                      value: rememberMe,
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                    SizedBox(
                      width: s.w(10),
                    ),
                    Text(
                      "Remember Me",
                      style: AppTextStyles.buttonText(
                        16,
                      ),
                    ),
                  ],
                ),
              ),

              // =======================================================
              // LOGIN BUTTON
              // =======================================================

              Positioned(
                bottom: s.h(156),
                left:
                (MediaQuery.of(context).size.width -
                    s.w(191)) /
                    2,
                child: AppButton(
                  width: s.w(191),
                  height: s.h(50),
                  text: "Log In",
                  isLoading: authProvider.isLoading,
                  onPressed: _login,
                ),
              ),

              // =======================================================
              // SIGN UP PROMPT
              // =======================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: s.h(50),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.buttonText(
                        16,
                      ),
                      children: [
                        const TextSpan(
                          text: "Don't have an account? ",
                        ),
                        WidgetSpan(
                          alignment:
                          PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () {
                              context.push('/signup');
                            },
                            child: Text(
                              "Sign Up",
                              style: AppTextStyles.buttonText(
                                16,
                              ),
                            ),
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
    );
  }

  // =============================================================
  // DISPOSE
  // =============================================================

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();

    super.dispose();
  }

  // =============================================================
  // LOGIN
  // =============================================================

  Future<void> _login() async {
    final email = emailController.text.trim();

    final password = passwordController.text;

    // -----------------------------------------------------------
    // EMAIL VALIDATION
    // -----------------------------------------------------------

    if (email.isEmpty) {
      AppToast.error(
        context,
        "Please enter your email address.",
      );
      return;
    }

    if (!Validators.isValidEmail(email)) {
      AppToast.error(
        context,
        "Please enter a valid email address.",
      );
      return;
    }

    // -----------------------------------------------------------
    // PASSWORD VALIDATION
    // -----------------------------------------------------------

    if (password.isEmpty) {
      AppToast.error(
        context,
        "Please enter your password.",
      );
      return;
    }

    // -----------------------------------------------------------
    // LOGIN
    // -----------------------------------------------------------

    try {
      await context.read<AuthProvider>().login(
        email: email,
        password: password,
        rememberMe: rememberMe,
      );

      if (!mounted) return;

      AppToast.success(
        context,
        "Login successful!",
      );

      context.go('/home');
    } catch (e) {
      if (!mounted) return;

      AppToast.error(
        context,
        "Invalid email or password.",
      );
    }
  }
}