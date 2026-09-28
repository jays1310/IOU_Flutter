import 'package:flutter/material.dart';
import '../../core/utils/app_scaler.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_text_styles.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_checkbox.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/utils/validators.dart';
import '../../core/utils/app_toast.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool rememberMe = false;
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);
    final authProvider = context.watch<AuthProvider>();
    return Scaffold(
      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: SafeArea(
        child: Stack(
          children: [
            /// Background Image
            Positioned(
              left: 0,
              right: 0,
              top: 155,
              child: Opacity(
                opacity: 0.2,
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

            /// Back Arrow
            Positioned(
              left: s.w(16),
              top: s.h(16),
              child: GestureDetector(
                onTap: () {
                  context.pop();
                },
                child: Opacity(
                  opacity: 0.8,
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

            /// Welcome Text
            Positioned(
              left: s.w(32),
              top: s.h(104),
              child: SizedBox(
                width: s.w(297),
                height: s.h(184),
                child: Text(
                  "Welcome",
                  style: AppTextStyles.welcomeText(s.sp(48)),
                ),
              ),
            ),

            /// Back!
            Positioned(
              left: s.w(32),
              top: s.h(155),
              child: Text(
                "Back!",
                style: AppTextStyles.welcomeBackText(s.sp(48)),
              ),
            ),

            /// User Detail TextField
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

            /// Password TextField
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
                    padding: EdgeInsets.fromLTRB(17, 14, 10, 14),
                  ),
                ),
              ),
            ),

            /// Forgot Password
            Positioned(
              right: s.w(20),
              top: s.h(453),
              child: GestureDetector(
                onTap: () {
                  // TODO: Navigate to Forgot Password screen
                },
                child: Text(
                  "Forgot Password?",
                  style: AppTextStyles.buttonText(
                    16,
                  ),
                ),
              ),
            ),

            /// Remember Me
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

                  SizedBox(width: s.w(10)),

                  Text(
                    "Remember Me",
                    style: AppTextStyles.buttonText(
                      16,
                    ),
                  ),
                ],
              ),
            ),

            /// Login Button
            Positioned(
              bottom: s.h(156),
              left: (MediaQuery.of(context).size.width - s.w(191)) / 2,
              child: AppButton(
                width: s.w(191),
                height: s.h(50),
                text: "Log In",
                isLoading: authProvider.isLoading,
                onPressed: _login,
              ),
            ),

            /// Sign Up Prompt
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
                        alignment: PlaceholderAlignment.middle,
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
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty) {
      AppToast.error(context, "Please enter your email address.");
      return;
    }

    if (!Validators.isValidEmail(email)) {
      AppToast.error(context, "Please enter a valid email address.");
      return;
    }

    if (password.isEmpty) {
      AppToast.error(context, "Please enter your password.");
      return;
    }

    try {
      await context.read<AuthProvider>().login(
        email: email,
        password: password,
      );

      AppToast.success(context, "Login successful!");
      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      AppToast.error(context, "Invalid email or password.");
    }
  }
}