import 'package:flutter/material.dart';
import 'package:pinput/pinput.dart';
import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../widgets/app_button.dart';
import '../../models/user_model.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../core/utils/app_toast.dart';
import '../../providers/auth_provider.dart';

class OtpVerificationScreen extends StatefulWidget {
  final UserModel user;
  final String verificationId;

  const OtpVerificationScreen({
    super.key,
    required this.user,
    required this.verificationId,
  });

  @override
  State<OtpVerificationScreen> createState() =>
      _OtpVerificationScreenState();
}

class _OtpVerificationScreenState
    extends State<OtpVerificationScreen> {

  final TextEditingController otpController =
  TextEditingController();

  @override
  void dispose() {
    otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final defaultPinTheme = PinTheme(
      width: s.w(52),
      height: s.h(58),
      textStyle: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [

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

            Positioned(
              left: s.w(32),
              top: s.h(104),
              child: Text(
                "Verify",
                style: AppTextStyles.welcomeText(s.sp(48)),
              ),
            ),

            Positioned(
              left: s.w(32),
              top: s.h(155),
              child: Text(
                "Phone Number",
                style: AppTextStyles.welcomeBackText(s.sp(40)),
              ),
            ),

            Positioned(
              left: s.w(32),
              right: s.w(32),
              top: s.h(245),
              child: Text(
                "We've sent a verification code to\n${widget.user.phoneNumber}",
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
            ),

            Positioned(
              left: s.w(28),
              right: s.w(28),
              top: s.h(320),
              child: Pinput(
                controller: otpController,
                length: 6,
                defaultPinTheme: defaultPinTheme,
              ),
            ),

            Positioned(
              bottom: s.h(180),
              left: (MediaQuery.of(context).size.width - s.w(190)) / 2,
              child: AppButton(
                width: s.w(190),
                height: s.h(50),
                text: "Verify OTP",
                onPressed: _verifyOtp,
              ),
            ),

            Positioned(
              left: 0,
              right: 0,
              bottom: s.h(110),
              child: Center(
                child: Text(
                  "Resend OTP",
                  style: AppTextStyles.buttonText(16),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _verifyOtp() async {
    final otp = otpController.text.trim();

    if (otp.length != 6) {
      AppToast.error(
        context,
        "Please enter the 6-digit verification code.",
      );
      return;
    }

    try {
      await context.read<AuthProvider>().verifyOtp(
        verificationId: widget.verificationId,
        otp: otp,
      );

      await context.read<AuthProvider>().signUp(
        widget.user,
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

      if (message.startsWith("Exception: ")) {
        message = message.replaceFirst("Exception: ", "");
      }

      AppToast.error(
        context,
        message,
      );
    }
  }
}