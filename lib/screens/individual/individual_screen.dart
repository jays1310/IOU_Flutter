import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'widgets/settle_up_dialog.dart';

import '../../core/constants/app_assets.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';

import '../../features/transactions/widgets/expense_timeline.dart';
import '../../models/registered_user_model.dart';
import '../../providers/transaction_provider.dart';

import '../group/widgets/group_action_buttons.dart';
import 'widgets/add_expense_dialog.dart';

class IndividualScreen extends StatefulWidget {
  final RegisteredUserModel user;

  const IndividualScreen({
    super.key,
    required this.user,
  });

  @override
  State<IndividualScreen> createState() =>
      _IndividualScreenState();
}

class _IndividualScreenState extends State<IndividualScreen> {
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadIndividualData();
    });
  }

  // ================================================================
  // INITIAL LOAD
  // ================================================================

  Future<void> _loadIndividualData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final transactionProvider =
      context.read<TransactionProvider>();

      await Future.wait([
        transactionProvider.getIndividualTransactions(
          otherUserId: widget.user.id,
        ),
        transactionProvider.getIndividualBalance(
          otherUserId: widget.user.id,
        ),
      ]);

      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = e.toString();
      });
    }
  }

  // ================================================================
  // SILENT REFRESH
  // ================================================================

  Future<void> _refreshIndividualData() async {
    try {
      final transactionProvider =
      context.read<TransactionProvider>();

      await Future.wait([
        transactionProvider.getIndividualTransactions(
          otherUserId: widget.user.id,
        ),
        transactionProvider.getIndividualBalance(
          otherUserId: widget.user.id,
        ),
      ]);
    } catch (e) {
      debugPrint(
        'FAILED TO REFRESH INDIVIDUAL DATA: $e',
      );
    }
  }

  // ================================================================
  // FORMAT AMOUNT
  // ================================================================

  String _formatAmount(double amount) {
    return '₹${amount.toStringAsFixed(2)}';
  }

  // ================================================================
  // BALANCE
  // ================================================================

  Widget _buildBalance(BuildContext context) {
    final s = AppScaler(context);

    final transactionProvider =
    context.watch<TransactionProvider>();

    final balanceData =
        transactionProvider.individualBalance;

    if (balanceData == null) {
      return const SizedBox.shrink();
    }

    final double balance =
        (balanceData['balance'] as num?)?.toDouble() ?? 0.0;

    // --------------------------------------------------------------
    // SETTLED
    // --------------------------------------------------------------

    if (balance == 0) {
      return Padding(
        padding: EdgeInsets.only(
          top: s.h(12),
          left: s.w(18),
          right: s.w(18),
        ),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: s.w(16),
            vertical: s.h(10),
          ),
          decoration: BoxDecoration(
            color: AppColors.success.withValues(
              alpha: 0.08,
            ),
            borderRadius: BorderRadius.circular(
              s.w(14),
            ),
            border: Border.all(
              color: AppColors.success.withValues(
                alpha: 0.20,
              ),
            ),
          ),
          child: Text(
            'Settled up',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.greenAccent,
              fontFamily: 'Raleway',
              fontSize: s.sp(14),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    final bool otherOwesYou = balance > 0;

    return Padding(
      padding: EdgeInsets.only(
        top: s.h(12),
        left: s.w(18),
        right: s.w(18),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: s.w(16),
          vertical: s.h(10),
        ),
        decoration: BoxDecoration(
          color: otherOwesYou
              ? AppColors.success.withValues(
            alpha: 0.07,
          )
              : AppColors.error.withValues(
            alpha: 0.07,
          ),
          borderRadius: BorderRadius.circular(
            s.w(14),
          ),
          border: Border.all(
            color: otherOwesYou
                ? AppColors.success.withValues(
              alpha: 0.18,
            )
                : AppColors.error.withValues(
              alpha: 0.18,
            ),
          ),
        ),
        child: Text(
          otherOwesYou
              ? '${widget.user.username} owes you ${_formatAmount(balance.abs())}'
              : 'You owe ${widget.user.username} ${_formatAmount(balance.abs())}',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: otherOwesYou
                ? Colors.greenAccent[400]
                : Colors.redAccent[700],
            fontFamily: 'Raleway',
            fontSize: s.sp(17),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }

  // ================================================================
  // TRANSACTION AREA
  // ================================================================

  Widget _buildTransactionArea(BuildContext context) {
    final transactionProvider =
    context.watch<TransactionProvider>();

    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(
          color: AppColors.accent,
          strokeWidth: 2.5,
        ),
      );
    }

    if (_errorMessage != null) {
      final s = AppScaler(context);

      return Center(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: s.w(30),
          ),
          child: Container(
            width: double.infinity,
            padding: EdgeInsets.all(
              s.w(20),
            ),
            decoration: BoxDecoration(
              color: AppColors.background.withValues(
                alpha: 0.72,
              ),
              borderRadius: BorderRadius.circular(
                s.w(18),
              ),
              border: Border.all(
                color: AppColors.error.withValues(
                  alpha: 0.22,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.error_outline,
                  color: AppColors.error,
                  size: s.w(40),
                ),
                SizedBox(
                  height: s.h(10),
                ),
                Text(
                  'Unable to load transactions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: s.sp(16),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(
                  height: s.h(6),
                ),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(
                      alpha: 0.55,
                    ),
                    fontFamily: 'Raleway',
                    fontSize: s.sp(12),
                  ),
                ),
                SizedBox(
                  height: s.h(14),
                ),
                TextButton(
                  onPressed: _loadIndividualData,
                  child: Text(
                    'Retry',
                    style: TextStyle(
                      color: AppColors.accent,
                      fontFamily: 'Raleway',
                      fontSize: s.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        _buildBalance(context),

        SizedBox(
          height: AppScaler(context).h(12),
        ),

        Expanded(
          child: ExpenseTimeline(
            transactions:
            transactionProvider.individualTransactions,
            individualUser: widget.user,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final String username =
    widget.user.username.trim();

    final String initials = username.isEmpty
        ? '?'
        : username
        .split(' ')
        .where((part) => part.isNotEmpty)
        .map((part) => part[0])
        .take(2)
        .join()
        .toUpperCase();

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
                  // INDIVIDUAL TOOLBAR
                  // =======================================================

                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.025,
                      ),
                      border: Border(
                        bottom: BorderSide(
                          color: AppColors.primary.withValues(
                            alpha: 0.12,
                          ),
                          width: 1,
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(
                            alpha: 0.05,
                          ),
                          blurRadius: 14,
                          spreadRadius: 0,
                          offset: const Offset(
                            0,
                            4,
                          ),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: s.w(12),
                      vertical: s.h(10),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // =================================================
                        // CENTERED USERNAME
                        // =================================================

                        Positioned(
                          left: 0,
                          right: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: s.w(100),
                            ),
                            child: Text(
                              username,
                              textAlign: TextAlign.center,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontSize: s.sp(20),
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.2,
                              ),
                            ),
                          ),
                        ),

                        // =================================================
                        // LEFT SIDE
                        // =================================================

                        Align(
                          alignment: Alignment.centerLeft,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // ---------------------------------------------
                              // BACK ARROW
                              // ---------------------------------------------

                              GestureDetector(
                                onTap: () =>
                                    Navigator.pop(context),
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

                              SizedBox(
                                width: s.w(14),
                              ),

                              // ---------------------------------------------
                              // GRADIENT AVATAR
                              // ---------------------------------------------

                              GestureDetector(
                                onTap: () {},
                                child: Container(
                                  width: s.w(46),
                                  height: s.w(46),
                                  padding: EdgeInsets.all(
                                    s.w(2),
                                  ),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    gradient:
                                    const LinearGradient(
                                      begin:
                                      Alignment.topLeft,
                                      end:
                                      Alignment.bottomRight,
                                      colors: [
                                        AppColors.accent,
                                        AppColors.primary,
                                      ],
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: AppColors.primary
                                            .withValues(
                                          alpha: 0.20,
                                        ),
                                        blurRadius: 12,
                                        spreadRadius: 1,
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    decoration:
                                    BoxDecoration(
                                      shape: BoxShape.circle,
                                      color:
                                      AppColors.background,
                                    ),
                                    alignment:
                                    Alignment.center,
                                    child: Text(
                                      initials,
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Raleway',
                                        fontSize: s.sp(15),
                                        fontWeight:
                                        FontWeight.w700,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // =======================================================
                  // TRANSACTION AREA
                  // =======================================================

                  Expanded(
                    child: Stack(
                      children: [
                        _buildTransactionArea(
                          context,
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
                                      user: widget.user,
                                    ),
                              );

                              if (result == true &&
                                  mounted) {
                                await _refreshIndividualData();
                              }
                            },

                            // ---------------------------------------------
                            // SETTLE UP
                            // ---------------------------------------------

                            onSettleUp: () async {
                              final balance =
                                  (context
                                      .read<
                                      TransactionProvider>()
                                      .individualBalance?[
                                  'balance'] as num?)
                                      ?.toDouble() ??
                                      0.0;

                              if (balance >= 0) {
                                return;
                              }

                              final result =
                              await showDialog<bool>(
                                context: context,
                                builder: (_) =>
                                    SettleUpDialog(
                                      user: widget.user,
                                      outstandingAmount:
                                      balance.abs(),
                                    ),
                              );

                              if (result == true &&
                                  mounted) {
                                await _refreshIndividualData();
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