import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';

class ChangePasswordSheet extends StatefulWidget {
  const ChangePasswordSheet({super.key});

  @override
  State<ChangePasswordSheet> createState() =>
      _ChangePasswordSheetState();
}

class _ChangePasswordSheetState
    extends State<ChangePasswordSheet> {
  final TextEditingController _currentPasswordController =
  TextEditingController();

  final TextEditingController _newPasswordController =
  TextEditingController();

  final TextEditingController _confirmPasswordController =
  TextEditingController();

  String? _errorMessage;
  bool _isChanging = false;

  @override
  void dispose() {
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // =============================================================
  // CHANGE PASSWORD
  // =============================================================

  Future<void> _changePassword() async {
    final currentPassword =
        _currentPasswordController.text;

    final newPassword =
        _newPasswordController.text;

    final confirmPassword =
        _confirmPasswordController.text;

    // -----------------------------------------------------------
    // Current password
    // -----------------------------------------------------------

    if (currentPassword.isEmpty) {
      setState(() {
        _errorMessage =
        'Please enter your current password.';
      });
      return;
    }

    // -----------------------------------------------------------
    // New password
    // -----------------------------------------------------------

    if (newPassword.isEmpty) {
      setState(() {
        _errorMessage =
        'Please enter a new password.';
      });
      return;
    }

    // -----------------------------------------------------------
    // Confirm password
    // -----------------------------------------------------------

    if (confirmPassword.isEmpty) {
      setState(() {
        _errorMessage =
        'Please confirm your new password.';
      });
      return;
    }

    // -----------------------------------------------------------
    // Password match
    // -----------------------------------------------------------

    if (newPassword != confirmPassword) {
      setState(() {
        _errorMessage =
        'New password and confirm password do not match.';
      });
      return;
    }

    // -----------------------------------------------------------
    // Same password check
    // -----------------------------------------------------------

    if (currentPassword == newPassword) {
      setState(() {
        _errorMessage =
        'New password must be different from your current password.';
      });
      return;
    }

    // -----------------------------------------------------------
    // Start backend request
    // -----------------------------------------------------------

    setState(() {
      _isChanging = true;
      _errorMessage = null;
    });

    try {
      await context.read<AuthProvider>().changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      if (!mounted) return;

      // ---------------------------------------------------------
      // Password changed successfully
      // ---------------------------------------------------------

      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Password changed successfully.',
          ),
        ),
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
        _isChanging = false;
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
        MediaQuery.of(context).viewInsets.bottom +
            s.h(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =======================================================
          // SHEET HANDLE
          // =======================================================

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

          // =======================================================
          // TITLE
          // =======================================================

          Text(
            'Change Password',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          SizedBox(height: s.h(20)),

          // =======================================================
          // CURRENT PASSWORD
          // =======================================================

          AppTextField(
            controller: _currentPasswordController,
            hintText: 'Current Password',
            obscureText: true,
            isPassword: true,
          ),

          SizedBox(height: s.h(14)),

          // =======================================================
          // NEW PASSWORD
          // =======================================================

          AppTextField(
            controller: _newPasswordController,
            hintText: 'New Password',
            obscureText: true,
            isPassword: true,
          ),

          SizedBox(height: s.h(14)),

          // =======================================================
          // CONFIRM NEW PASSWORD
          // =======================================================

          AppTextField(
            controller: _confirmPasswordController,
            hintText: 'Confirm New Password',
            obscureText: true,
            isPassword: true,
          ),

          // =======================================================
          // ERROR MESSAGE
          // =======================================================

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
                  fontFamily: 'Raleway',
                  fontSize: s.sp(13),
                ),
              ),
            ),
          ],

          SizedBox(height: s.h(30)),

          // =======================================================
          // BUTTONS
          // =======================================================

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isChanging
                      ? null
                      : () {
                    Navigator.pop(context);
                  },
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
                    text: _isChanging
                        ? 'Changing...'
                        : 'Change',
                    width: double.infinity,
                    height: s.h(38),
                    borderRadius: BorderRadius.circular(30),
                    showShadow: false,
                    onPressed:
                    _isChanging ? null : _changePassword,
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