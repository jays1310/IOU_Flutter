import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';

class GroupCard extends StatelessWidget {
  final GroupModel group;
  final VoidCallback? onTap;

  const GroupCard({
    super.key,
    required this.group,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final memberText = group.members.length == 1
        ? '${group.members.length} Member'
        : '${group.members.length} Members';

    return Padding(
      padding: EdgeInsets.only(
        bottom: s.h(12),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(
          s.w(16),
        ),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: s.w(18),
            vertical: s.h(14),
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(
              s.w(16),
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.25,
              ),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // =====================================================
              // GROUP HEADER
              // =====================================================

              Row(
                children: [
                  Icon(
                    Icons.groups_rounded,
                    color: AppColors.accent,
                    size: s.sp(28),
                  ),
                  SizedBox(
                    width: s.w(12),
                  ),
                  Expanded(
                    child: Text(
                      group.groupName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.welcomeText(
                        s.sp(20),
                      ),
                    ),
                  ),
                  Text(
                    memberText,
                    style: AppTextStyles.buttonText(
                      s.sp(13),
                    ).copyWith(
                      color: AppColors.grey,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: s.h(12),
              ),

              // =====================================================
              // DIVIDER
              // =====================================================

              Divider(
                color: Colors.white.withValues(
                  alpha: 0.15,
                ),
                thickness: 1,
                height: 1,
              ),

              SizedBox(
                height: s.h(12),
              ),

              // =====================================================
              // I OWE
              // =====================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Text(
                    'I Owe',
                    style: AppTextStyles.buttonText(
                      s.sp(18),
                    ).copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${group.iOwe.toStringAsFixed(0)}',
                    style: AppTextStyles.welcomeText(
                      s.sp(22),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),

              SizedBox(
                height: s.h(8),
              ),

              // =====================================================
              // OWES ME
              // =====================================================

              Row(
                mainAxisAlignment:
                MainAxisAlignment.spaceBetween,
                crossAxisAlignment:
                CrossAxisAlignment.center,
                children: [
                  Text(
                    'Owes Me',
                    style: AppTextStyles.buttonText(
                      s.sp(18),
                    ).copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '₹${group.owesMe.toStringAsFixed(0)}',
                    style: AppTextStyles.welcomeText(
                      s.sp(22),
                    ).copyWith(
                      fontWeight: FontWeight.w700,
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