import 'package:flutter/material.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../widgets/app_icon.dart';
import '../../profile/profile_screen.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final scaler = AppScaler(context);

    return Container(
      width: double.infinity,
      color: AppColors.background,
      padding: EdgeInsets.symmetric(
        horizontal: scaler.w(20),
        vertical: scaler.h(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // =========================================================
          // IOU LOGO
          // =========================================================

          Image.asset(
            AppAssets.logoNoBackground,
            width: scaler.w(58),
            height: scaler.h(34),
            fit: BoxFit.contain,
          ),

          SizedBox(
            width: scaler.w(6),
          ),

          // =========================================================
          // APP NAME
          // =========================================================

          Text(
            'I Owe You',
            style: AppTextStyles.buttonText(
              scaler.sp(18),
            ),
          ),

          const Spacer(),

          // =========================================================
          // PROFILE BUTTON
          // =========================================================

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfileScreen(),
                ),
              );
            },
            child: Container(
              width: scaler.w(34),
              height: scaler.w(34),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.accent,
                  width: 2,
                ),
              ),
              child: Center(
                child: AppIcon(
                  AppAssets.userIcon,
                  size: scaler.w(23),
                  padding: EdgeInsets.zero,
                  color: AppColors.accent,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}