import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';

class HomeSearchBar extends StatelessWidget {
  final ValueChanged<String>? onChanged;

  const HomeSearchBar({
    super.key,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final scaler = AppScaler(context);

    return Container(
      height: scaler.h(48),
      padding: EdgeInsets.symmetric(
        horizontal: scaler.w(14),
      ),
      decoration: BoxDecoration(
        // ============================================================
        // GLASS BACKGROUND
        // ============================================================

        color: Colors.white.withValues(
          alpha: 0.055,
        ),

        borderRadius: BorderRadius.circular(
          scaler.h(30),
        ),

        // ============================================================
        // PURPLE GLASS BORDER
        // ============================================================

        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.22,
          ),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // ==========================================================
          // SEARCH ICON
          // ==========================================================

          Icon(
            Icons.search_rounded,
            color: AppColors.accent,
            size: scaler.sp(22),
          ),

          SizedBox(
            width: scaler.w(8),
          ),

          // ==========================================================
          // SEARCH FIELD
          // ==========================================================

          Expanded(
            child: TextField(
              cursorColor: AppColors.accent,
              onChanged: onChanged,
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
                fontSize: scaler.sp(14),
              ),
              decoration: InputDecoration(
                hintText: 'Search groups or people...',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(
                    alpha: 0.45,
                  ),
                  fontFamily: 'Raleway',
                  fontSize: scaler.sp(14),
                ),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                isCollapsed: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}