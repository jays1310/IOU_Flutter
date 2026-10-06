import 'package:flutter/material.dart';
import 'change_password_sheet.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';

import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

import 'package:go_router/go_router.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);
    final user = context.watch<AuthProvider>().currentUser;

    final username = user?.username ?? '';
    final initials = username.isNotEmpty
        ? username
        .trim()
        .split(' ')
        .where((e) => e.isNotEmpty)
        .take(2)
        .map((e) => e[0].toUpperCase())
        .join()
        : '?';

    return Scaffold(
      backgroundColor: AppColors.background,

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ===========================================================
              // AMBIENT TOP-RIGHT GLOW
              // ===========================================================

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
                        AppColors.primary.withValues(alpha: 0.16),
                        AppColors.primary.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // ===========================================================
              // AMBIENT BOTTOM-LEFT GLOW
              // ===========================================================

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
                        AppColors.accent.withValues(alpha: 0.12),
                        AppColors.accent.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),

              // ===========================================================
              // MONEY TRANSFER BACKGROUND
              // ===========================================================

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

              // ===========================================================
              // MAIN CONTENT
              // ===========================================================

              Column(
                children: [
                  // =======================================================
                  // HEADER
                  // =======================================================

                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: s.w(12),
                      vertical: s.h(10),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.025),
                      border: Border(
                        bottom: BorderSide(
                          color: Colors.white.withValues(alpha: 0.06),
                          width: 1,
                        ),
                      ),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Opacity(
                              opacity: 0.85,
                              child: SizedBox(
                                width: s.w(50),
                                height: s.h(48),
                                child: Image.asset(
                                  AppAssets.backArrow,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        ),

                        Text(
                          'Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                            fontSize: s.sp(22),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =======================================================
                  // PROFILE CONTENT
                  // =======================================================

                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.symmetric(
                        horizontal: s.w(20),
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: s.h(30)),

                          // =================================================
                          // PROFILE AVATAR
                          // =================================================

                          Container(
                            width: s.w(96),
                            height: s.w(96),
                            padding: EdgeInsets.all(s.w(3)),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  AppColors.accent,
                                  AppColors.primary,
                                ],
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.primary.withValues(
                                    alpha: 0.28,
                                  ),
                                  blurRadius: 24,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.background.withValues(
                                  alpha: 0.90,
                                ),
                                border: Border.all(
                                  color: Colors.white.withValues(
                                    alpha: 0.10,
                                  ),
                                  width: 1,
                                ),
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                initials,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'Raleway',
                                  fontSize: s.sp(27),
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: s.h(18)),

                          // =================================================
                          // USERNAME
                          // =================================================

                          Text(
                            username,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Raleway',
                              fontSize: s.sp(20),
                              fontWeight: FontWeight.w600,
                            ),
                          ),

                          SizedBox(height: s.h(6)),

                          // =================================================
                          // PHONE
                          // =================================================

                          Text(
                            user?.phoneNumber ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontFamily: 'Raleway',
                              fontSize: s.sp(15),
                            ),
                          ),

                          SizedBox(height: s.h(4)),

                          // =================================================
                          // EMAIL
                          // =================================================

                          Text(
                            user?.email ?? '',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.62),
                              fontFamily: 'Raleway',
                              fontSize: s.sp(15),
                            ),
                          ),

                          SizedBox(height: s.h(38)),

                          // =================================================
                          // CHANGE PASSWORD
                          // =================================================

                          _ProfileActionTile(
                            icon: Icons.lock_outline_rounded,
                            title: 'Change Password',
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: AppColors.background,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(s.h(24)),
                                  ),
                                ),
                                builder: (_) {
                                  return const ChangePasswordSheet();
                                },
                              );
                            },
                            scaler: s,
                          ),

                          SizedBox(height: s.h(14)),

                          // =================================================
                          // LOGOUT
                          // =================================================

                          _ProfileActionTile(
                            icon: Icons.logout_rounded,
                            title: 'Logout',
                            isLogout: true,
                            onTap: () async {
                              final shouldLogout =
                              await showDialog<bool>(
                                context: context,
                                builder: (dialogContext) {
                                  return AlertDialog(
                                    backgroundColor: AppColors.card,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        s.h(18),
                                      ),
                                    ),
                                    title: const Text(
                                      'Logout',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Raleway',
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    content: Text(
                                      'Are you sure you want to logout?',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.70,
                                        ),
                                        fontFamily: 'Raleway',
                                      ),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            dialogContext,
                                            false,
                                          );
                                        },
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: AppColors.accent,
                                            fontFamily: 'Raleway',
                                          ),
                                        ),
                                      ),
                                      TextButton(
                                        onPressed: () {
                                          Navigator.pop(
                                            dialogContext,
                                            true,
                                          );
                                        },
                                        child: const Text(
                                          'Logout',
                                          style: TextStyle(
                                            color: AppColors.error,
                                            fontFamily: 'Raleway',
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              );

                              if (shouldLogout != true ||
                                  !context.mounted) {
                                return;
                              }

                              await context.read<AuthProvider>().logout();

                              if (!context.mounted) return;

                              context.go('/get-started');
                            },
                            scaler: s,
                          ),

                          SizedBox(height: s.h(24)),
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
    );
  }
}

// ===========================================================================
// PROFILE ACTION TILE
// ===========================================================================

class _ProfileActionTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final AppScaler scaler;
  final bool isLogout;

  const _ProfileActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
    required this.scaler,
    this.isLogout = false,
  });

  @override
  Widget build(BuildContext context) {
    final iconColor =
    isLogout ? AppColors.error : AppColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: scaler.h(62),
        padding: EdgeInsets.symmetric(
          horizontal: scaler.w(18),
        ),
        decoration: BoxDecoration(
          color: AppColors.background.withValues(alpha: 0.72),
          borderRadius: BorderRadius.circular(
            scaler.h(16),
          ),
          border: Border.all(
            color: isLogout
                ? AppColors.error.withValues(alpha: 0.22)
                : AppColors.primary.withValues(alpha: 0.24),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // =============================================================
            // ICON
            // =============================================================

            Container(
              width: scaler.w(40),
              height: scaler.w(40),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: iconColor.withValues(alpha: 0.10),
                border: Border.all(
                  color: iconColor.withValues(alpha: 0.20),
                ),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: scaler.sp(21),
              ),
            ),

            SizedBox(width: scaler.w(14)),

            // =============================================================
            // TITLE
            // =============================================================

            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: scaler.sp(15),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // =============================================================
            // ARROW
            // =============================================================

            Icon(
              Icons.chevron_right_rounded,
              color: Colors.white.withValues(alpha: 0.50),
              size: scaler.sp(22),
            ),
          ],
        ),
      ),
    );
  }
}