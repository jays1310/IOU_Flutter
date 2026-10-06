import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/settle_up_dialog.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';

import '../../features/transactions/widgets/expense_timeline.dart';
import '../../models/group_model.dart';
import '../../providers/transaction_provider.dart';

import 'widgets/add_expense_dialog.dart';
import 'widgets/group_action_buttons.dart';
import 'widgets/group_toolbar.dart';
import 'widgets/owe_summary.dart';

class GroupScreen extends StatefulWidget {
  final GroupModel group;

  const GroupScreen({
    super.key,
    required this.group,
  });

  @override
  State<GroupScreen> createState() => _GroupScreenState();
}

class _GroupScreenState extends State<GroupScreen> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTransactions();
      _loadBalanceSummary();
    });
  }

  // ================================================================
  // LOAD TRANSACTIONS
  // ================================================================

  Future<void> _loadTransactions() async {
    try {
      await context
          .read<TransactionProvider>()
          .getGroupTransactions(
        groupId: widget.group.id,
      );
    } catch (e) {
      debugPrint(
        'FAILED TO LOAD TRANSACTIONS: $e',
      );
    }
  }

  // ================================================================
  // LOAD BALANCE SUMMARY
  // ================================================================

  Future<void> _loadBalanceSummary() async {
    try {
      final balances = await context
          .read<TransactionProvider>()
          .getGroupBalanceSummary(
        groupId: widget.group.id,
      );

      debugPrint(
        '========== BALANCE SUMMARY ==========',
      );

      for (final balance in balances) {
        debugPrint(
          '${balance['username']}: ${balance['balance']}',
        );
      }

      debugPrint(
        '=====================================',
      );
    } catch (e) {
      debugPrint(
        'FAILED TO LOAD BALANCE SUMMARY: $e',
      );
    }
  }

  // ================================================================
  // REFRESH GROUP DATA
  // ================================================================

  Future<void> _refreshGroupData() async {
    await Future.wait([
      _loadTransactions(),
      _loadBalanceSummary(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Scaffold(
      backgroundColor: AppColors.background,

      resizeToAvoidBottomInset: false,

      body: Container(
        decoration: const BoxDecoration(
          gradient: AppColors.screenGradient,
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // ===========================================================
              // TOP-RIGHT AMBIENT GLOW
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
                        AppColors.primary.withValues(
                          alpha: 0.16,
                        ),
                        AppColors.primary.withValues(
                          alpha: 0.0,
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // ===========================================================
              // BOTTOM-LEFT AMBIENT GLOW
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
                        AppColors.accent.withValues(
                          alpha: 0.12,
                        ),
                        AppColors.accent.withValues(
                          alpha: 0.0,
                        ),
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
              // MAIN SCREEN
              // ===========================================================

              Column(
                children: [
                  // =======================================================
                  // GROUP TOOLBAR
                  // =======================================================

                  GroupToolbar(
                    group: widget.group,
                  ),

                  // =======================================================
                  // GROUP BALANCE SUMMARY
                  // =======================================================

                  OweSummary(),

                  // =======================================================
                  // TRANSACTION AREA
                  // =======================================================

                  Expanded(
                    child: Stack(
                      children: [
                        // =================================================
                        // TRANSACTION TIMELINE
                        // =================================================

                        Consumer<TransactionProvider>(
                          builder: (
                              context,
                              transactionProvider,
                              child,
                              ) {
                            if (transactionProvider.isLoading) {
                              return Center(
                                child:
                                CircularProgressIndicator(
                                  color: AppColors.accent,
                                  strokeWidth: 2.5,
                                ),
                              );
                            }

                            return ExpenseTimeline(
                              transactions:
                              transactionProvider.transactions,
                              group: widget.group,
                            );
                          },
                        ),

                        // =================================================
                        // FIXED BOTTOM ACTION BUTTONS
                        // =================================================

                        Positioned(
                          right: s.w(40),
                          bottom: s.h(40),
                          child: GroupActionButtons(
                            // ---------------------------------------------
                            // ADD EXPENSE
                            // ---------------------------------------------

                            onAddExpense: () async {
                              final result =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    AddExpenseDialog(
                                      group: widget.group,
                                    ),
                              );

                              if (result == true &&
                                  mounted) {
                                await _refreshGroupData();
                              }
                            },

                            // ---------------------------------------------
                            // SETTLE UP
                            // ---------------------------------------------

                            onSettleUp: () async {
                              final result =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    SettleUpDialog(
                                      group: widget.group,
                                    ),
                              );

                              if (result == true &&
                                  mounted) {
                                await _refreshGroupData();
                              }
                            },
                          ),
                        ),
                      ],
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