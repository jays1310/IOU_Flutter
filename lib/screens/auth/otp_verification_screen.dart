import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../widgets/app_button.dart';
import '../../models/user_model.dart';
import '../../core/utils/app_toast.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final UserModel? user;
  final String verificationId;

  // Forgot Password fields
  final bool isPasswordReset;
  final String? resetPhoneNumber;
  final String? resetPassword;

  const OtpVerificationScreen({
    super.key,
    this.user,
    required this.verificationId,
    this.isPasswordReset = false,
    this.resetPhoneNumber,
    this.resetPassword,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {
  final TextEditingController otpController =
  TextEditingController();

  bool _isVerifying = false;

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    // =============================================================
    // DEFAULT OTP THEME
    // =============================================================

    final defaultPinTheme = PinTheme(
      width: s.w(50),
      height: s.h(58),
      textStyle: TextStyle(
        fontSize: s.sp(22),
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.08,
        ),
        borderRadius: BorderRadius.circular(
          s.w(12),
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.35,
          ),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.08,
            ),
            blurRadius: 12,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    // =============================================================
    // FOCUSED OTP THEME
    // =============================================================

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.12,
        ),
        borderRadius: BorderRadius.circular(
          s.w(12),
        ),
        border: Border.all(
          color: AppColors.accent,
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withValues(
              alpha: 0.25,
            ),
            blurRadius: 14,
            spreadRadius: 1,
          ),
        ],
      ),
    );

    // =============================================================
    // FILLED OTP THEME
    // =============================================================

    final submittedPinTheme =
    defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(
          alpha: 0.16,
        ),
        borderRadius: BorderRadius.circular(
          s.w(12),
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.65,
          ),
          width: 1,
        ),
      ),
    );

    return Scaffold(
      // ===========================================================
      // IOU DARK PURPLE THEME
      // ===========================================================

      backgroundColor: AppColors.background,
      resizeToAvoidBottomInset: false,
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // =====================================================
              // TOP RIGHT PURPLE GLOW
              // =====================================================

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

              // =====================================================
              // BOTTOM LEFT PURPLE GLOW
              // =====================================================

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

              // =====================================================
              // BACKGROUND MONEY TRANSFER IMAGE
              // =====================================================

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

              // =====================================================
              // TITLE
              // =====================================================

              Positioned(
                left: s.w(32),
                top: s.h(104),
                child: Text(
                  widget.isPasswordReset
                      ? "Reset"
                      : "Verify",
                  style: AppTextStyles.welcomeText(
                    s.sp(48),
                  ),
                ),
              ),

              // =====================================================
              // SUBTITLE
              // =====================================================

              Positioned(
                left: s.w(32),
                top: s.h(155),
                child: Text(
                  widget.isPasswordReset
                      ? "Password"
                      : "Phone Number",
                  style:
                  AppTextStyles.welcomeBackText(
                    s.sp(40),
                  ),
                ),
              ),

              // =====================================================
              // DESCRIPTION
              // =====================================================

              Positioned(
                left: s.w(32),
                right: s.w(32),
                top: s.h(245),
                child: Text(
                  "We've sent a verification code to\n"
                      "${widget.isPasswordReset
                      ? widget.resetPhoneNumber ?? ''
                      : widget.user?.phoneNumber ?? ''}",
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.70,
                    ),
                    fontSize: s.sp(16),
                    height: 1.5,
                  ),
                ),
              ),

              // =====================================================
              // OTP INPUT
              // =====================================================

              Positioned(
                left: s.w(28),
                right: s.w(28),
                top: s.h(320),
                child: Pinput(
                  controller: otpController,
                  length: 6,
                  defaultPinTheme:
                  defaultPinTheme,
                  focusedPinTheme:
                  focusedPinTheme,
                  submittedPinTheme:
                  submittedPinTheme,
                  showCursor: true,
                  cursor: Container(
                    width: 2,
                    height: s.h(24),
                    decoration: BoxDecoration(
                      color: AppColors.accent,
                      borderRadius:
                      BorderRadius.circular(2),
                    ),
                  ),
                  keyboardType:
                  TextInputType.number,
                  onCompleted: (_) {
                    // User can still press Verify OTP.
                  },
                ),
              ),

              // =====================================================
              // VERIFY BUTTON
              // =====================================================

              Positioned(
                bottom: s.h(180),
                left:
                (MediaQuery.of(context)
                    .size
                    .width -
                    s.w(190)) /
                    2,
                child: AppButton(
                  width: s.w(190),
                  height: s.h(50),
                  text: _isVerifying
                      ? "Verifying..."
                      : "Verify OTP",
                  onPressed: _isVerifying
                      ? null
                      : _verifyOtp,
                ),
              ),

              // =====================================================
              // RESEND OTP
              // =====================================================

              Positioned(
                left: 0,
                right: 0,
                bottom: s.h(110),
                child: Center(
                  child: Text(
                    "Resend OTP",
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
    );
  }

  // ===============================================================
  // VERIFY OTP
  // ===============================================================

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    // -------------------------------------------------------------
    // OTP VALIDATION
    // -------------------------------------------------------------

    if (otp.length != 6) {
      AppToast.error(
        context,
        "Please enter a valid 6-digit OTP.",
      );
      return;
    }

    // -------------------------------------------------------------
    // SIGNUP SAFETY CHECK
    // -------------------------------------------------------------

    if (!widget.isPasswordReset &&
        widget.user == null) {
      AppToast.error(
        context,
        "Signup information is missing.",
      );
      return;
    }

    // -------------------------------------------------------------
    // FORGOT PASSWORD SAFETY CHECK
    // -------------------------------------------------------------

    if (widget.isPasswordReset &&
        (widget.resetPhoneNumber == null ||
            widget.resetPassword == null)) {
      AppToast.error(
        context,
        "Password reset information is missing.",
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });

    try {
      final authProvider =
      context.read<AuthProvider>();

      // ===========================================================
      // STEP 1: VERIFY OTP
      // ===========================================================

      await authProvider.verifyOtp(
        verificationId:
        widget.verificationId,
        otp: otp,
      );

      // ===========================================================
      // STEP 2A: FORGOT PASSWORD
      // ===========================================================

      if (widget.isPasswordReset) {
        await authProvider.resetForgotPassword(
          phoneNumber:
          widget.resetPhoneNumber!,
          newPassword:
          widget.resetPassword!,
        );

        if (!mounted) return;

        AppToast.success(
          context,
          "Password changed successfully!",
        );

        // User must login again
        // with the new password.
        context.go('/login');

        return;
      }

      // ===========================================================
      // STEP 2B: SIGNUP
      // ===========================================================

      await authProvider.signUp(
        widget.user!,
      );

      if (!mounted) return;

      AppToast.success(
        context,
        "Account created successfully!",
      );

      context.go('/login');
    } catch (e) {
      if (!mounted) return;

      String message = e.toString();

      if (message.startsWith(
        "Exception: ",
      )) {
        message = message.replaceFirst(
          "Exception: ",
          "",
        );
      }

      AppToast.error(
        context,
        message,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isVerifying = false;
        });
      }
    }
  }
}