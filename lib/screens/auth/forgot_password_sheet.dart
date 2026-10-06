import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'otp_verification_screen.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final TextEditingController _phoneController =
  TextEditingController();

  final TextEditingController _passwordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  bool _isChecking = false;
  String? _errorMessage;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _continue() async {
    final phoneNumber = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    // ------------------------------------------------------------
    // Validate phone number
    // ------------------------------------------------------------

    if (phoneNumber.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your mobile number.';
      });
      return;
    }

    if (phoneNumber.length != 10) {
      setState(() {
        _errorMessage =
        'Please enter a valid 10-digit mobile number.';
      });
      return;
    }

    // ------------------------------------------------------------
    // Validate password
    // ------------------------------------------------------------

    if (password.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your new password.';
      });
      return;
    }

    if (!Validators.isValidPassword(password)) {
      setState(() {
        _errorMessage =
        'Password must be at least 8 characters long.';
      });
      return;
    }

    // ------------------------------------------------------------
    // Validate confirm password
    // ------------------------------------------------------------

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage = 'Please confirm your new password.';
      });
      return;
    }

    if (!Validators.doPasswordsMatch(
      password,
      confirmPassword,
    )) {
      setState(() {
        _errorMessage = 'Passwords do not match.';
      });
      return;
    }

    setState(() {
      _isChecking = true;
      _errorMessage = null;
    });

    try {
      // ----------------------------------------------------------
      // STEP 1:
      // Check whether the phone number exists in the database.
      // ----------------------------------------------------------

      await context.read<AuthProvider>().checkForgotPasswordPhone(
        phoneNumber: phoneNumber,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // STEP 2:
      // Start Firebase phone verification.
      // ----------------------------------------------------------

      await context.read<AuthProvider>().verifyPhoneNumber(
        phoneNumber: '+91$phoneNumber',

        verificationCompleted: (credential) {
          // Automatic verification can happen on supported devices.
          // We intentionally do not reset the password here.
          //
          // Password reset must happen through the OTP verification
          // flow below.
        },

        verificationFailed: (exception) {
          if (!mounted) return;

          setState(() {
            _isChecking = false;
            _errorMessage = exception.message ??
                'Unable to send OTP. Please try again.';
          });
        },

        codeSent: (verificationId, forceResendingToken) {
          if (!mounted) return;

          // Close the Forgot Password bottom sheet first.
          Navigator.pop(context);

          // Open the existing OTP verification screen
          // in password-reset mode.
          context.push(
            '/otp-verification',
            extra: OtpVerificationScreen(
              verificationId: verificationId,
              isPasswordReset: true,
              resetPhoneNumber: phoneNumber,
              resetPassword: password,
            ),
          );
        },

        codeAutoRetrievalTimeout: (verificationId) {
          // Nothing needs to be done here.
          //
          // The user can still enter the OTP that was sent.
        },
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring('Exception: '.length);
      }

      setState(() {
        _errorMessage = errorMessage;
        _isChecking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Padding(
      padding: EdgeInsets.only(
        left: s.w(20),
        right: s.w(20),
        top: s.h(20),
        bottom:
        MediaQuery.of(context).viewInsets.bottom + s.h(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // --------------------------------------------------------
          // Sheet handle
          // --------------------------------------------------------

          Center(
            child: Container(
              width: s.w(50),
              height: s.h(5),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          SizedBox(height: s.h(24)),

          // --------------------------------------------------------
          // Title
          // --------------------------------------------------------

          Text(
            'Forgot Password',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          SizedBox(height: s.h(20)),

          // --------------------------------------------------------
          // Mobile Number
          // --------------------------------------------------------

          AppTextField(
            controller: _phoneController,
            hintText: 'Enter Mobile Number',
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(10),
            ],
          ),

          SizedBox(height: s.h(12)),

          // --------------------------------------------------------
          // New Password
          // --------------------------------------------------------

          AppTextField(
            controller: _passwordController,
            hintText: 'New Password',
            obscureText: true,
            isPassword: true,
          ),

          SizedBox(height: s.h(12)),

          // --------------------------------------------------------
          // Confirm Password
          // --------------------------------------------------------

          AppTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm Password',
            obscureText: true,
            isPassword: true,
          ),

          // --------------------------------------------------------
          // Error message
          // --------------------------------------------------------

          if (_errorMessage != null) ...[
            SizedBox(height: s.h(8)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: s.w(4),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: s.sp(13),
                ),
              ),
            ),
          ],

          SizedBox(height: s.h(30)),

          // --------------------------------------------------------
          // Buttons
          // --------------------------------------------------------

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isChecking
                      ? null
                      : () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.buttonText(18).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),

              SizedBox(width: s.w(12)),

              Expanded(
                child: SizedBox(
                  height: s.h(38),
                  child: AppButton(
                    text: _isChecking
                        ? 'Sending...'
                        : 'Continue',
                    width: double.infinity,
                    height: s.h(38),
                    borderRadius: BorderRadius.circular(30),
                    showShadow: false,
                    onPressed:
                    _isChecking ? null : _continue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}