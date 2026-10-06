import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';

class EqualSplitPreview extends StatelessWidget {
  final List<GroupMemberModel> members;
  final Map<String, double> shares;
  final AppScaler s;

  const EqualSplitPreview({
    super.key,
    required this.members,
    required this.shares,
    required this.s,
  });

  String _formatAmount(double amount) {
    return amount.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    if (members.isEmpty || shares.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(s.w(12)),
      decoration: BoxDecoration(
        color: const Color(0xFF18111E),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Equal Split',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontSize: s.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: s.h(10)),
          ...members.map(
                (member) {
              final share = shares[member.id] ?? 0;

              return Padding(
                padding: EdgeInsets.only(
                  bottom: s.h(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.username,
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Raleway',
                          fontSize: s.sp(13),
                        ),
                      ),
                    ),
                    Text(
                      '₹${_formatAmount(share)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(13),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}