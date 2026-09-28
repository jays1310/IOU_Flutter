import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_scaler.dart';

class EmptyGroups extends StatelessWidget {
  const EmptyGroups({super.key});

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'No Groups Yet',
            style: AppTextStyles.welcomeText(
              s.sp(24),
            ),
          ),

          SizedBox(height: s.h(10)),

          SizedBox(
            width: s.w(250),
            child: Text(
              'Tap the + button below to create a new group or join an existing one.',
              textAlign: TextAlign.center,
              style: AppTextStyles.buttonText(
                s.sp(14),
              ).copyWith(
                color: AppColors.grey,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}