import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';
import '../../../models/registered_user_model.dart';
import '../../../models/transaction_model.dart';

class ExpenseTimeline extends StatefulWidget {
  final List<TransactionModel> transactions;

  // Used for Group transactions.
  final GroupModel? group;

  // Used for Individual transactions.
  final RegisteredUserModel? individualUser;

  const ExpenseTimeline({
    super.key,
    required this.transactions,
    this.group,
    this.individualUser,
  }) : assert(
  group != null || individualUser != null,
  'Either group or individualUser must be provided.',
  );

  @override
  State<ExpenseTimeline> createState() => _ExpenseTimelineState();
}

class _ExpenseTimelineState extends State<ExpenseTimeline> {
  final ScrollController _scrollController = ScrollController();

  List<TransactionModel> _orderedTransactions = [];

  OverlayEntry? _focusOverlayEntry;

  String? _focusedTransactionId;

  final Map<String, GlobalKey> _transactionKeys = {};

  @override
  void initState() {
    super.initState();

    _orderedTransactions = _sortTransactions(
      widget.transactions,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToLatest();
    });
  }

  @override
  void didUpdateWidget(covariant ExpenseTimeline oldWidget) {
    super.didUpdateWidget(oldWidget);

    final transactionsChanged =
        oldWidget.transactions.length != widget.transactions.length ||
            !_sameTransactions(
              oldWidget.transactions,
              widget.transactions,
            );

    if (transactionsChanged) {
      _orderedTransactions = _sortTransactions(
        widget.transactions,
      );

      if (_focusedTransactionId != null &&
          !_orderedTransactions.any(
                (transaction) =>
            transaction.id == _focusedTransactionId,
          )) {
        _removeFocus();
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _scrollToLatest();
        }
      });
    }
  }

  bool _sameTransactions(
      List<TransactionModel> oldTransactions,
      List<TransactionModel> newTransactions,
      ) {
    if (oldTransactions.length != newTransactions.length) {
      return false;
    }

    for (int i = 0; i < oldTransactions.length; i++) {
      if (oldTransactions[i].id != newTransactions[i].id) {
        return false;
      }
    }

    return true;
  }

  List<TransactionModel> _sortTransactions(
      List<TransactionModel> transactions,
      ) {
    final sorted = List<TransactionModel>.from(
      transactions,
    );

    sorted.sort(
          (a, b) => a.createdAt.compareTo(b.createdAt),
    );

    return sorted;
  }

  void _scrollToLatest() {
    if (!_scrollController.hasClients) {
      return;
    }

    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  String _getMemberName(String userId) {
    // ---------------------------------------------------------------
    // INDIVIDUAL MODE
    // ---------------------------------------------------------------
    if (widget.individualUser != null) {
      if (userId == widget.individualUser!.id) {
        return widget.individualUser!.username;
      }

      return 'You';
    }

    // ---------------------------------------------------------------
    // GROUP MODE
    // ---------------------------------------------------------------
    final group = widget.group!;

    final member = group.memberDetails.where(
          (member) => member.id == userId,
    );

    if (member.isEmpty) {
      return 'Unknown';
    }

    return member.first.username;
  }

  GlobalKey _getTransactionKey(String transactionId) {
    return _transactionKeys.putIfAbsent(
      transactionId,
          () => GlobalKey(),
    );
  }

  // ===================================================================
  // FOCUS TRANSACTION
  // ===================================================================

  void _focusTransaction(
      TransactionModel transaction,
      ) {
    if (_focusOverlayEntry != null) {
      return;
    }

    final transactionKey = _getTransactionKey(
      transaction.id,
    );

    final cardContext = transactionKey.currentContext;

    if (cardContext == null) {
      debugPrint(
        'FOCUS FAILED: Card context not found for ${transaction.id}',
      );
      return;
    }

    final renderObject = cardContext.findRenderObject();

    if (renderObject is! RenderBox) {
      debugPrint(
        'FOCUS FAILED: Card render object is not a RenderBox',
      );
      return;
    }

    final position = renderObject.localToGlobal(
      Offset.zero,
    );

    final size = renderObject.size;

    final cardRect = Rect.fromLTWH(
      position.dx,
      position.dy,
      size.width,
      size.height,
    );

    debugPrint(
      'FOCUSING TRANSACTION: ${transaction.id}',
    );

    debugPrint(
      'CARD POSITION: $position',
    );

    debugPrint(
      'CARD SIZE: $size',
    );

    _focusedTransactionId = transaction.id;

    _focusOverlayEntry = OverlayEntry(
      builder: (overlayContext) {
        return _FocusedTransactionOverlay(
          transaction: transaction,
          getMemberName: _getMemberName,
          s: AppScaler(overlayContext),
          cardRect: cardRect,
          onDismiss: _removeFocus,
        );
      },
    );

    Overlay.of(
      context,
      rootOverlay: true,
    ).insert(
      _focusOverlayEntry!,
    );

    if (mounted) {
      setState(() {});
    }
  }

  // ===================================================================
  // REMOVE FOCUS
  // ===================================================================

  void _removeFocus() {
    _focusOverlayEntry?.remove();
    _focusOverlayEntry = null;

    if (mounted) {
      setState(() {
        _focusedTransactionId = null;
      });
    } else {
      _focusedTransactionId = null;
    }
  }

  @override
  void dispose() {
    _focusOverlayEntry?.remove();
    _focusOverlayEntry = null;

    _scrollController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    if (_orderedTransactions.isEmpty) {
      return Center(
        child: Text(
          'No expenses yet',
          style: TextStyle(
            color: Colors.white54,
            fontFamily: 'Raleway',
            fontSize: s.sp(14),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: EdgeInsets.fromLTRB(
        s.w(16),
        s.h(16),
        s.w(16),
        s.h(100),
      ),
      itemCount: _orderedTransactions.length,
      itemBuilder: (context, index) {
        final transaction = _orderedTransactions[index];

        final isFocused =
            transaction.id == _focusedTransactionId;

        return _NormalTransactionItem(
          transaction: transaction,
          getMemberName: _getMemberName,
          s: s,
          cardKey: _getTransactionKey(
            transaction.id,
          ),
          isFocused: isFocused,
          onTap: () {
            _focusTransaction(
              transaction,
            );
          },
        );
      },
    );
  }
}

// =====================================================================
// NORMAL TRANSACTION ITEM
// =====================================================================

class _NormalTransactionItem extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(String userId) getMemberName;
  final AppScaler s;
  final GlobalKey cardKey;
  final bool isFocused;
  final VoidCallback onTap;

  const _NormalTransactionItem({
    required this.transaction,
    required this.getMemberName,
    required this.s,
    required this.cardKey,
    required this.isFocused,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isSettlement =
        transaction.transactionType == 'settlement';

    return Padding(
      padding: EdgeInsets.only(
        bottom: s.h(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(
              left: s.w(4),
              right: s.w(4),
              bottom: s.h(8),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.white70.withValues(
                      alpha: 20,
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: s.w(8),
                  ),
                  child: Text(
                    _formatDateTime(
                      transaction.createdAt,
                    ),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Raleway',
                      fontSize: s.sp(14),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: Container(
                    height: 1,
                    color: Colors.white70.withValues(
                      alpha: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),

          GestureDetector(
            onTap: onTap,
            child: Opacity(
              opacity: isFocused ? 0.0 : 1.0,
              child: Container(
                key: cardKey,
                width: double.infinity,
                padding: EdgeInsets.all(
                  s.w(14),
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF29202F),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSettlement
                        ? Colors.greenAccent.withValues(
                      alpha: 0.22,
                    )
                        : AppColors.primary.withValues(
                      alpha: 0.22,
                    ),
                  ),
                ),
                child: isSettlement
                    ? _CompactSettlementContent(
                  transaction: transaction,
                  getMemberName: getMemberName,
                  s: s,
                )
                    : _CompactExpenseContent(
                  transaction: transaction,
                  getMemberName: getMemberName,
                  s: s,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];

    final hour = dateTime.hour % 12 == 0
        ? 12
        : dateTime.hour % 12;

    final minute =
    dateTime.minute.toString().padLeft(2, '0');

    final period =
    dateTime.hour >= 12 ? 'PM' : 'AM';

    return '${dateTime.day} ${months[dateTime.month - 1]} '
        '${dateTime.year} : $hour:$minute $period';
  }
}

// =====================================================================
// COMPACT EXPENSE CONTENT
// =====================================================================

class _CompactExpenseContent extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(String userId) getMemberName;
  final AppScaler s;

  const _CompactExpenseContent({
    required this.transaction,
    required this.getMemberName,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final paidByName = transaction.paidBy == null
        ? 'Unknown'
        : getMemberName(
      transaction.paidBy!,
    );

    final splitText = _getSplitText(
      transaction.splitType,
    );

    final participants = transaction.participants
        .where(
          (participant) =>
      participant.userId != transaction.paidBy,
    )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '$paidByName paid',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              '₹${transaction.amount.toStringAsFixed(2)}',
              style: TextStyle(
                color: Colors.white,
                fontFamily: 'Raleway',
                fontSize: s.sp(13),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),

        SizedBox(height: s.h(12)),

        Text(
          splitText,
          style: TextStyle(
            color: Colors.white70,
            fontFamily: 'Raleway',
            fontSize: s.sp(11),
            fontWeight: FontWeight.w500,
          ),
        ),

        SizedBox(height: s.h(12)),

        Text(
          'I owe',
          style: TextStyle(
            color: Colors.white54,
            fontFamily: 'Raleway',
            fontSize: s.sp(11),
            fontWeight: FontWeight.w600,
          ),
        ),

        SizedBox(height: s.h(8)),

        if (participants.isEmpty)
          Text(
            'No other members',
            style: TextStyle(
              color: Colors.white38,
              fontFamily: 'Raleway',
              fontSize: s.sp(10),
            ),
          )
        else
          ...participants.map(
                (participant) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: s.h(5),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      color: Colors.white54,
                      size: s.sp(16),
                    ),
                    SizedBox(width: s.w(8)),
                    Expanded(
                      child: Text(
                        getMemberName(
                          participant.userId,
                        ),
                        style: TextStyle(
                          color: Colors.white70,
                          fontFamily: 'Raleway',
                          fontSize: s.sp(11),
                        ),
                      ),
                    ),
                    Text(
                      '₹${participant.share.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(11),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }

  String _getSplitText(String splitType) {
    switch (splitType.toLowerCase()) {
      case 'equal':
      case 'equally':
        return 'Split equally';

      case 'percentage':
        return 'Split by percentage';

      case 'custom':
        return 'Custom split';

      default:
        return 'Split';
    }
  }
}

// =====================================================================
// COMPACT SETTLEMENT CONTENT
// =====================================================================

class _CompactSettlementContent extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(String userId) getMemberName;
  final AppScaler s;

  const _CompactSettlementContent({
    required this.transaction,
    required this.getMemberName,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final payerName = transaction.payer == null
        ? 'Unknown'
        : getMemberName(
      transaction.payer!,
    );

    final receiverName = transaction.receiver == null
        ? 'Unknown'
        : getMemberName(
      transaction.receiver!,
    );

    return Row(
      children: [
        Icon(
          Icons.check_circle_outline,
          color: Colors.greenAccent,
          size: s.sp(20),
        ),
        SizedBox(width: s.w(10)),
        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                '$payerName paid $receiverName',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: s.h(4)),
              Text(
                'Settlement',
                style: TextStyle(
                  color: Colors.white54,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(10),
                ),
              ),
            ],
          ),
        ),
        Text(
          '₹${transaction.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: Colors.greenAccent,
            fontFamily: 'Raleway',
            fontSize: s.sp(13),
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// FULL SCREEN FOCUS OVERLAY
// =====================================================================

class _FocusedTransactionOverlay extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(String userId) getMemberName;
  final AppScaler s;
  final Rect cardRect;
  final VoidCallback onDismiss;

  const _FocusedTransactionOverlay({
    required this.transaction,
    required this.getMemberName,
    required this.s,
    required this.cardRect,
    required this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    final isSettlement =
        transaction.transactionType == 'settlement';

    return Material(
      color: Colors.transparent,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: onDismiss,
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 7,
                  sigmaY: 7,
                ),
                child: Container(
                  color: Colors.black.withValues(
                    alpha: 0.68,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            left: cardRect.left,
            top: cardRect.top,
            width: cardRect.width,
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {},
              child: isSettlement
                  ? _SettlementCard(
                transaction: transaction,
                getMemberName: getMemberName,
                s: s,
              )
                  : _ExpenseCard(
                transaction: transaction,
                getMemberName: getMemberName,
                s: s,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// EXISTING DETAILED EXPENSE CARD
// =====================================================================

class _ExpenseCard extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(String userId) getMemberName;
  final AppScaler s;

  const _ExpenseCard({
    required this.transaction,
    required this.getMemberName,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final paidByName = transaction.paidBy == null
        ? 'Unknown'
        : getMemberName(
      transaction.paidBy!,
    );

    return Container(
      margin: EdgeInsets.only(
        bottom: s.h(14),
      ),
      padding: EdgeInsets.all(
        s.w(14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF29202F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.18,
            ),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.w(38),
                height: s.w(38),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(
                    alpha: 0.15,
                  ),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: AppColors.accent,
                  size: s.sp(20),
                ),
              ),
              SizedBox(width: s.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description.isEmpty
                          ? 'Expense'
                          : transaction.description,
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(15),
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: s.h(4)),
                    Text(
                      'Paid by $paidByName',
                      style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(12),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(16),
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: s.h(14)),

          Divider(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
            height: 1,
          ),

          SizedBox(height: s.h(12)),

          Text(
            'Split',
            style: TextStyle(
              color: Colors.white70,
              fontFamily: 'Raleway',
              fontSize: s.sp(12),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: s.h(8)),

          ...transaction.participants.map(
                (participant) {
              return Padding(
                padding: EdgeInsets.only(
                  bottom: s.h(6),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        getMemberName(
                          participant.userId,
                        ),
                        style: TextStyle(
                          color: Colors.white60,
                          fontFamily: 'Raleway',
                          fontSize: s.sp(12),
                        ),
                      ),
                    ),
                    Text(
                      '₹${participant.share.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(12),
                        fontWeight:
                        FontWeight.w600,
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

// =====================================================================
// EXISTING DETAILED SETTLEMENT CARD
// =====================================================================

class _SettlementCard extends StatelessWidget {
  final TransactionModel transaction;
  final String Function(String userId) getMemberName;
  final AppScaler s;

  const _SettlementCard({
    required this.transaction,
    required this.getMemberName,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final payerName = transaction.payer == null
        ? 'Unknown'
        : getMemberName(
      transaction.payer!,
    );

    final receiverName = transaction.receiver == null
        ? 'Unknown'
        : getMemberName(
      transaction.receiver!,
    );

    return Container(
      margin: EdgeInsets.only(
        bottom: s.h(14),
      ),
      padding: EdgeInsets.all(
        s.w(14),
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF29202F),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.greenAccent.withValues(
            alpha: 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.greenAccent.withValues(
              alpha: 0.12,
            ),
            blurRadius: 24,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.w(38),
                height: s.w(38),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.withValues(
                    alpha: 0.12,
                  ),
                  borderRadius:
                  BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.check_circle_outline,
                  color: Colors.greenAccent,
                  size: s.sp(20),
                ),
              ),
              SizedBox(width: s.w(12)),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Settlement',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(15),
                        fontWeight:
                        FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: s.h(4)),
                    Text(
                      'Paid by $payerName',
                      style: TextStyle(
                        color: Colors.white54,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(12),
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '₹${transaction.amount.toStringAsFixed(2)}',
                style: TextStyle(
                  color: Colors.greenAccent,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(16),
                  fontWeight:
                  FontWeight.w700,
                ),
              ),
            ],
          ),

          SizedBox(height: s.h(14)),

          Divider(
            color: Colors.white.withValues(
              alpha: 0.08,
            ),
            height: 1,
          ),

          SizedBox(height: s.h(12)),

          Row(
            children: [
              Icon(
                Icons.arrow_forward,
                color: Colors.white38,
                size: s.sp(15),
              ),
              SizedBox(width: s.w(8)),
              Text(
                'Paid to $receiverName',
                style: TextStyle(
                  color: Colors.white60,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}