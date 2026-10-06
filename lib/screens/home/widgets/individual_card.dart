import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/utils/app_scaler.dart';

class IndividualCard extends StatelessWidget {
  final String username;
  final String phoneNumber;
  final double balance;
  final VoidCallback? onTap;

  const IndividualCard({
    super.key,
    required this.username,
    required this.phoneNumber,
    required this.balance,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final bool youOwe = balance < 0;
    final bool theyOwe = balance > 0;

    final String balanceLabel;

    if (youOwe) {
      balanceLabel = 'I Owe';
    } else if (theyOwe) {
      balanceLabel = 'Owes Me';
    } else {
      balanceLabel = 'Settled Up';
    }

    final double displayAmount = balance.abs();

    return Padding(
      padding: EdgeInsets.only(bottom: s.h(12)),
      child: InkWell(
        borderRadius: BorderRadius.circular(s.w(16)),
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: s.w(18),
            vertical: s.h(14),
          ),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(s.w(16)),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.person_rounded,
                    color: AppColors.accent,
                    size: s.sp(28),
                  ),

                  SizedBox(width: s.w(12)),

                  Expanded(
                    child: Text(
                      username,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.welcomeText(
                        s.sp(20),
                      ),
                    ),
                  ),

                  SizedBox(width: s.w(8)),

                  Text(
                    phoneNumber,
                    style: AppTextStyles.buttonText(
                      s.sp(13),
                    ).copyWith(
                      color: Colors.white70,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),

              SizedBox(height: s.h(12)),

              Divider(
                color: Colors.white.withValues(alpha: 0.15),
                thickness: 1,
                height: 1,
              ),

              SizedBox(height: s.h(12)),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    balanceLabel,
                    style: AppTextStyles.buttonText(
                      s.sp(19),
                    ).copyWith(
                      color: AppColors.accent,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    '₹${_formatAmount(displayAmount)}',
                    style: AppTextStyles.welcomeText(
                      s.sp(24),
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

  String _formatAmount(double amount) {
    if (amount == amount.roundToDouble()) {
      return amount.toStringAsFixed(0);
    }

    return amount.toStringAsFixed(2);
  }
}