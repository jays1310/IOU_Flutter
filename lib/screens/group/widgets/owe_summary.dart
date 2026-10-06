import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_scaler.dart';
import '../../../providers/transaction_provider.dart';

class OweSummary extends StatelessWidget {
  const OweSummary({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Consumer<TransactionProvider>(
      builder: (
          context,
          transactionProvider,
          child,
          ) {
        final balances = transactionProvider.groupBalances;

        final visibleBalances = balances.where((balance) {
          final amount =
              (balance['balance'] as num?)?.toDouble() ?? 0.0;

          return amount != 0;
        }).toList();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: s.w(20),
            vertical: s.h(12),
          ),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.12),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
              bottom: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'OWE SUMMARY',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Rale-way',
                  fontSize: s.sp(15),
                  fontWeight: FontWeight.w700,
                ),
              ),

              if (visibleBalances.isNotEmpty) ...[
                SizedBox(height: s.h(8)),

                ...visibleBalances.map(
                      (balance) {
                    final username =
                        balance['username']?.toString() ?? 'Unknown';

                    final amount =
                        (balance['balance'] as num?)?.toDouble() ?? 0.0;

                    final isOwedByUser = amount < 0;

                    final displayAmount = amount.abs();

                    return Padding(
                      padding: EdgeInsets.only(
                        bottom: s.h(6),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              isOwedByUser
                                  ? 'I owe $username'
                                  : '$username owes you',
                              style: TextStyle(
                                color: Colors.white70,
                                fontFamily: 'Rale-way',
                                fontSize: s.sp(14),
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          Text(
                            '₹${displayAmount.toStringAsFixed(2)}',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'Rale-way',
                              fontSize: s.sp(14),
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}