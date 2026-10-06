import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'terms_conditions_screen.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../core/utils/app_toast.dart';
import '../../core/utils/validators.dart';
import '../../models/user_model.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_checkbox.dart';
import '../../widgets/app_icon.dart';
import '../../widgets/app_text_field.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  bool acceptTerms = false;

  final TextEditingController usernameController =
  TextEditingController();

  final TextEditingController emailController =
  TextEditingController();

  final TextEditingController passwordController =
  TextEditingController();

  final TextEditingController confirmPasswordController =
  TextEditingController();

  final TextEditingController phoneController =
  TextEditingController();

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      // =========================================================
      // IOU DARK THEME
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
              // CREATE AN
              // =======================================================

              Positioned(
                left: s.w(32),
                top: s.h(104),
                child: SizedBox(
                  width: s.w(297),
                  height: s.h(184),
                  child: Text(
                    "Create An",
                    style: AppTextStyles.welcomeText(
                      s.sp(48),
                    ),
                  ),
                ),
              ),

              // =======================================================
              // ACCOUNT
              // =======================================================

              Positioned(
                left: s.w(32),
                top: s.h(155),
                child: Text(
                  "Account",
                  style: AppTextStyles.welcomeBackText(
                    s.sp(48),
                  ),
                ),
              ),

              // =======================================================
              // USERNAME
              // =======================================================

              Positioned(
                left: s.w(20),
                top: s.h(234),
                child: SizedBox(
                  width: s.w(358),
                  child: AppTextField(
                    controller: usernameController,
                    hintText: "User Name",
                    prefixIcon: const AppIcon(
                      AppAssets.userIcon,
                    ),
                  ),
                ),
              ),

              // =======================================================
              // PHONE NUMBER
              // =======================================================

              Positioned(
                left: s.w(20),
                top: s.h(306),
                child: SizedBox(
                  width: s.w(358),
                  child: AppTextField(
                    controller: phoneController,
                    hintText: "Phone Number",
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    prefixIcon: const AppIcon(
                      AppAssets.phone,
                    ),
                  ),
                ),
              ),

              // =======================================================
              // EMAIL
              // =======================================================

              Positioned(
                left: s.w(20),
                top: s.h(378),
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
              // PASSWORD
              // =======================================================

              Positioned(
                left: s.w(18),
                top: s.h(450),
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
              // CONFIRM PASSWORD
              // =======================================================

              Positioned(
                left: s.w(18),
                top: s.h(522),
                child: SizedBox(
                  width: s.w(362),
                  child: AppTextField(
                    controller: confirmPasswordController,
                    hintText: "Confirm Password",
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
              // TERMS & CONDITIONS
              // =======================================================

              Positioned(
                left: s.w(20),
                top: s.h(600),
                child: Row(
                  children: [
                    AppCheckbox(
                      value: acceptTerms,
                      onChanged: (value) {
                        setState(() {
                          acceptTerms = value ?? false;
                        });
                      },
                    ),
                    SizedBox(
                      width: s.w(10),
                    ),
                    RichText(
                      text: TextSpan(
                        style: AppTextStyles.buttonText(15),
                        children: [
                          const TextSpan(
                            text: "I agree to the ",
                          ),
                          WidgetSpan(
                            alignment: PlaceholderAlignment.middle,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const TermsConditionsScreen(),
                                  ),
                                );
                              },
                              child: Text(
                                "Terms & Conditions",
                                style: AppTextStyles.buttonText(
                                  15,
                                ).copyWith(
                                  color: AppColors.accent,
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: AppColors.accent,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // =======================================================
              // SIGN UP BUTTON
              // =======================================================

              Positioned(
                top: s.h(644),
                left:
                (MediaQuery.of(context).size.width -
                    s.w(190)) /
                    2,
                child: AppButton(
                  width: s.w(190),
                  height: s.h(50),
                  text: "Sign Up",
                  isLoading: authProvider.isLoading,
                  onPressed: _signUp,
                ),
              ),

              // =======================================================
              // LOGIN PROMPT
              // =======================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: s.h(50),
                child: Center(
                  child: RichText(
                    text: TextSpan(
                      style: AppTextStyles.buttonText(16),
                      children: [
                        const TextSpan(
                          text: "Already have an account? ",
                        ),
                        WidgetSpan(
                          alignment:
                          PlaceholderAlignment.middle,
                          child: GestureDetector(
                            onTap: () {
                              context.pop();
                            },
                            child: Text(
                              "Login",
                              style:
                              AppTextStyles.buttonText(
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
    usernameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    phoneController.dispose();

    super.dispose();
  }

  // =============================================================
  // SIGN UP
  // =============================================================

  Future<void> _signUp() async {
    final username = usernameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text;
    final confirmPassword =
        confirmPasswordController.text;
    final phoneNumber =
    phoneController.text.trim();

    // -----------------------------------------------------------
    // USERNAME VALIDATION
    // -----------------------------------------------------------

    if (!Validators.isValidUsername(username)) {
      AppToast.error(
        context,
        "Please enter your username.",
      );
      return;
    }

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
    // PHONE VALIDATION
    // -----------------------------------------------------------

    if (phoneNumber.isEmpty) {
      AppToast.error(
        context,
        "Please enter your phone number.",
      );
      return;
    }

    if (phoneNumber.length != 10) {
      AppToast.error(
        context,
        "Please enter a valid 10-digit phone number.",
      );
      return;
    }

    // -----------------------------------------------------------
    // PASSWORD VALIDATION
    // -----------------------------------------------------------

    if (password.isEmpty) {
      AppToast.error(
        context,
        "Please enter a password.",
      );
      return;
    }

    // Keep the existing validator behavior.
    if (password.length < 6) {
      AppToast.error(
        context,
        "Password must be at least 6 characters.",
      );
      return;
    }

    // -----------------------------------------------------------
    // CONFIRM PASSWORD
    // -----------------------------------------------------------

    if (confirmPassword.isEmpty) {
      AppToast.error(
        context,
        "Please confirm your password.",
      );
      return;
    }

    if (!Validators.doPasswordsMatch(
      password,
      confirmPassword,
    )) {
      AppToast.error(
        context,
        "Passwords do not match.",
      );
      return;
    }

    // -----------------------------------------------------------
    // TERMS
    // -----------------------------------------------------------

    if (!acceptTerms) {
      AppToast.error(
        context,
        "Please accept the Terms & Conditions.",
      );
      return;
    }

    // -----------------------------------------------------------
    // USER MODEL
    // -----------------------------------------------------------

    final user = UserModel(
      username: username,
      phoneNumber: phoneNumber,
      email: email,
      password: password,
    );

    // -----------------------------------------------------------
    // FIREBASE PHONE VERIFICATION
    // -----------------------------------------------------------

    try {
      await context
          .read<AuthProvider>()
          .verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',

        verificationCompleted: (credential) {},

        verificationFailed: (e) {
          debugPrint(
            "======================================",
          );

          debugPrint(
            "Firebase Error Code : ${e.code}",
          );

          debugPrint(
            "Firebase Error Msg  : ${e.message}",
          );

          debugPrint(
            "Firebase Exception  : $e",
          );

          debugPrint(
            "======================================",
          );

          AppToast.error(
            context,
            e.message ??
                "OTP verification failed.",
          );
        },

        codeSent: (
            verificationId,
            resendToken,
            ) {
          context.push(
            '/otp-verification',
            extra: {
              'user': user,
              'verificationId': verificationId,
            },
          );
        },

        codeAutoRetrievalTimeout:
            (verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;

      AppToast.error(
        context,
        "Failed to send OTP.",
      );
    }
  }
}