import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';
import '../../../providers/transaction_provider.dart';

class SettleUpDialog extends StatefulWidget {
  final GroupModel group;

  const SettleUpDialog({
    super.key,
    required this.group,
  });

  @override
  State<SettleUpDialog> createState() => _SettleUpDialogState();
}

class _SettleUpDialogState extends State<SettleUpDialog> {
  final TextEditingController amountController =
  TextEditingController();

  String? selectedReceiverId;

  bool _isLoadingBalances = true;
  bool _isSubmitting = false;

  List<Map<String, dynamic>> _payableMembers = [];

  double? get _selectedOutstandingAmount {
    if (selectedReceiverId == null) {
      return null;
    }

    for (final member in _payableMembers) {
      if (member['user_id'] == selectedReceiverId) {
        return (member['outstanding_amount'] as num?)?.toDouble();
      }
    }

    return null;
  }

  bool get _isSettleEnabled {
    if (_isLoadingBalances || _isSubmitting) {
      return false;
    }

    if (selectedReceiverId == null) {
      return false;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return false;
    }

    final outstandingAmount = _selectedOutstandingAmount;

    if (outstandingAmount == null) {
      return false;
    }

    return amount <= outstandingAmount;
  }

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadBalances();
    });
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _loadBalances() async {
    try {
      final balances = await context
          .read<TransactionProvider>()
          .getGroupBalanceSummary(
        groupId: widget.group.id,
      );

      if (!mounted) {
        return;
      }

      final payableMembers = <Map<String, dynamic>>[];

      for (final balance in balances) {
        final balanceValue =
            (balance['balance'] as num?)?.toDouble() ?? 0.0;

        // Negative balance means:
        // current user owes this member.
        if (balanceValue < 0) {
          payableMembers.add({
            ...balance,
            'outstanding_amount': balanceValue.abs(),
          });
        }
      }

      setState(() {
        _payableMembers = payableMembers;
        _isLoadingBalances = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isLoadingBalances = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  Future<void> _handleSettleUp() async {
    if (!_isSettleEnabled) {
      return;
    }

    final amount = double.parse(
      amountController.text.trim(),
    );

    final outstandingAmount = _selectedOutstandingAmount!;

    if (amount > outstandingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can settle a maximum of ₹${outstandingAmount.toStringAsFixed(2)}.',
          ),
          backgroundColor: Colors.redAccent,
        ),
      );

      return;
    }

    try {
      setState(() {
        _isSubmitting = true;
      });

      await context.read<TransactionProvider>().createSettlement(
        groupId: widget.group.id,
        receiverId: selectedReceiverId!,
        amount: amount,
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst('Exception: ', ''),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return MediaQuery.removeViewInsets(
      context: context,
      removeBottom: true,
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: s.w(18),
          vertical: s.h(20),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.88,
          ),
          child: Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF160A2D),
                  Color(0xFF0D0626),
                  Color(0xFF070220),
                ],
              ),
              borderRadius: BorderRadius.circular(s.w(20)),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.32),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(s.w(20)),
              child: Stack(
                children: [
                  // Top-right purple glow
                  Positioned(
                    top: -s.h(80),
                    right: -s.w(85),
                    child: Container(
                      width: s.w(190),
                      height: s.w(190),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.primary.withValues(alpha: 0.20),
                            AppColors.primary.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Bottom-left accent glow
                  Positioned(
                    bottom: -s.h(90),
                    left: -s.w(100),
                    child: Container(
                      width: s.w(210),
                      height: s.w(210),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            AppColors.accent.withValues(alpha: 0.12),
                            AppColors.accent.withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      s.w(22),
                      s.h(21),
                      s.w(22),
                      s.h(18),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                width: s.w(42),
                                height: s.w(42),
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      AppColors.accent,
                                      AppColors.primary,
                                    ],
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.25),
                                      blurRadius: 14,
                                      spreadRadius: 1,
                                    ),
                                  ],
                                ),
                                child: Icon(
                                  Icons.handshake_rounded,
                                  color: Colors.white,
                                  size: s.sp(21),
                                ),
                              ),

                              SizedBox(width: s.w(12)),

                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                  CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Settle Up',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: 'Rale-way',
                                        fontSize: s.sp(23),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    SizedBox(height: s.h(2)),
                                    Text(
                                      'Clear an outstanding balance',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.45),
                                        fontFamily: 'Rale-way',
                                        fontSize: s.sp(11),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: s.h(25)),

                          _FieldLabel(
                            text: 'Pay To',
                            s: s,
                          ),

                          SizedBox(height: s.h(8)),

                          if (_isLoadingBalances)
                            _StatusContainer(
                              s: s,
                              child: Row(
                                children: [
                                  SizedBox(
                                    width: s.w(17),
                                    height: s.w(17),
                                    child:
                                    const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.primary,
                                    ),
                                  ),
                                  SizedBox(width: s.w(11)),
                                  Text(
                                    'Loading balances...',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.50),
                                      fontFamily: 'Rale-way',
                                      fontSize: s.sp(13),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else if (_payableMembers.isEmpty)
                            _StatusContainer(
                              s: s,
                              child: Row(
                                children: [
                                  Container(
                                    width: s.w(30),
                                    height: s.w(30),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: AppColors.success
                                          .withValues(alpha: 0.12),
                                      border: Border.all(
                                        color: AppColors.success
                                            .withValues(alpha: 0.22),
                                      ),
                                    ),
                                    child: Icon(
                                      Icons.check_rounded,
                                      color: AppColors.success,
                                      size: s.sp(17),
                                    ),
                                  ),
                                  SizedBox(width: s.w(10)),
                                  Expanded(
                                    child: Text(
                                      'You have no outstanding balances.',
                                      style: TextStyle(
                                        color: Colors.white
                                            .withValues(alpha: 0.58),
                                        fontFamily: 'Rale-way',
                                        fontSize: s.sp(13),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          else
                            _MemberDropdown(
                              value: selectedReceiverId,
                              members: _payableMembers,
                              onChanged: (value) {
                                setState(() {
                                  selectedReceiverId = value;
                                  amountController.clear();
                                });
                              },
                              s: s,
                            ),

                          if (selectedReceiverId != null &&
                              _selectedOutstandingAmount != null) ...[
                            SizedBox(height: s.h(9)),
                            Container(
                              padding: EdgeInsets.symmetric(
                                horizontal: s.w(10),
                                vertical: s.h(6),
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primary
                                    .withValues(alpha: 0.08),
                                borderRadius:
                                BorderRadius.circular(s.w(8)),
                                border: Border.all(
                                  color: AppColors.primary
                                      .withValues(alpha: 0.15),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    color: AppColors.accent
                                        .withValues(alpha: 0.85),
                                    size: s.sp(14),
                                  ),
                                  SizedBox(width: s.w(6)),
                                  Text(
                                    'Outstanding: ₹${_selectedOutstandingAmount!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: Colors.white
                                          .withValues(alpha: 0.70),
                                      fontFamily: 'Rale-way',
                                      fontSize: s.sp(11),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],

                          SizedBox(height: s.h(19)),

                          _FieldLabel(
                            text: 'Amount',
                            s: s,
                          ),

                          SizedBox(height: s.h(8)),

                          _DialogTextField(
                            controller: amountController,
                            hintText: 'Enter settlement amount',
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                            s: s,
                          ),

                          if (selectedReceiverId != null &&
                              _selectedOutstandingAmount != null)
                            Padding(
                              padding: EdgeInsets.only(
                                top: s.h(7),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.info_outline_rounded,
                                    size: s.sp(12),
                                    color: _isAmountOverMaximum
                                        ? Colors.redAccent
                                        : Colors.white
                                        .withValues(alpha: 0.30),
                                  ),
                                  SizedBox(width: s.w(5)),
                                  Text(
                                    'Maximum: ₹${_selectedOutstandingAmount!.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      color: _isAmountOverMaximum
                                          ? Colors.redAccent
                                          : Colors.white
                                          .withValues(alpha: 0.38),
                                      fontFamily: 'Rale-way',
                                      fontSize: s.sp(10),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                          SizedBox(height: s.h(27)),

                          Row(
                            children: [
                              Expanded(
                                child: _DialogButton(
                                  text: 'Cancel',
                                  enabled: !_isSubmitting,
                                  onTap: () {
                                    Navigator.of(context).pop(false);
                                  },
                                  isPrimary: false,
                                  s: s,
                                ),
                              ),

                              SizedBox(width: s.w(11)),

                              Expanded(
                                child: _DialogButton(
                                  text: _isSubmitting
                                      ? 'Settling...'
                                      : 'Settle Up',
                                  enabled: _isSettleEnabled,
                                  onTap: _handleSettleUp,
                                  isPrimary: true,
                                  s: s,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool get _isAmountOverMaximum {
    if (_selectedOutstandingAmount == null) {
      return false;
    }

    final enteredAmount = double.tryParse(
      amountController.text.trim(),
    );

    if (enteredAmount == null) {
      return false;
    }

    return enteredAmount > _selectedOutstandingAmount!;
  }
}

class _FieldLabel extends StatelessWidget {
  final String text;
  final AppScaler s;

  const _FieldLabel({
    required this.text,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyle(
        color: Colors.white.withValues(alpha: 0.76),
        fontFamily: 'Rale-way',
        fontSize: s.sp(13),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatusContainer extends StatelessWidget {
  final Widget child;
  final AppScaler s;

  const _StatusContainer({
    required this.child,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: s.w(14),
        vertical: s.h(13),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.045),
        borderRadius: BorderRadius.circular(s.w(10)),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: child,
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final AppScaler s;

  const _DialogTextField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.s,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      onChanged: onChanged,
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Rale-way',
        fontSize: s.sp(14),
      ),
      cursorColor: AppColors.primary,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.34),
          fontFamily: 'Rale-way',
          fontSize: s.sp(13),
        ),
        prefixIcon: Padding(
          padding: EdgeInsets.only(
            left: s.w(12),
            right: s.w(9),
          ),
          child: Text(
            '₹',
            style: TextStyle(
              color: AppColors.accent.withValues(alpha: 0.85),
              fontFamily: 'Rale-way',
              fontSize: s.sp(18),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        prefixIconConstraints: const BoxConstraints(
          minWidth: 0,
          minHeight: 0,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.045),
        contentPadding: EdgeInsets.symmetric(
          horizontal: s.w(14),
          vertical: s.h(14),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.w(10)),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.09),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.w(10)),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.09),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.w(10)),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.85),
            width: 1.3,
          ),
        ),
      ),
    );
  }
}

class _MemberDropdown extends StatelessWidget {
  final String? value;
  final List<Map<String, dynamic>> members;
  final ValueChanged<String?> onChanged;
  final AppScaler s;

  const _MemberDropdown({
    required this.value,
    required this.members,
    required this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      isExpanded: true,
      dropdownColor: const Color(0xFF160A2D),
      borderRadius: BorderRadius.circular(s.w(12)),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: AppColors.accent.withValues(alpha: 0.80),
        size: s.sp(21),
      ),
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Rale-way',
        fontSize: s.sp(14),
      ),
      decoration: InputDecoration(
        hintText: 'Select member',
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.34),
          fontFamily: 'Rale-way',
          fontSize: s.sp(13),
        ),
        prefixIcon: Icon(
          Icons.person_outline_rounded,
          color: AppColors.accent.withValues(alpha: 0.70),
          size: s.sp(19),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.045),
        contentPadding: EdgeInsets.symmetric(
          horizontal: s.w(14),
          vertical: s.h(5),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.w(10)),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.09),
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.w(10)),
          borderSide: BorderSide(
            color: Colors.white.withValues(alpha: 0.09),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(s.w(10)),
          borderSide: BorderSide(
            color: AppColors.primary.withValues(alpha: 0.85),
            width: 1.3,
          ),
        ),
      ),
      items: members.map((member) {
        final username =
            member['username']?.toString() ?? 'Unknown';

        final outstandingAmount =
            (member['outstanding_amount'] as num?)
                ?.toDouble() ??
                0.0;

        return DropdownMenuItem<String>(
          value: member['user_id']?.toString(),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  username,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Rale-way',
                    fontSize: s.sp(14),
                  ),
                ),
              ),
              SizedBox(width: s.w(8)),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: s.w(7),
                  vertical: s.h(3),
                ),
                decoration: BoxDecoration(
                  color: AppColors.primary
                      .withValues(alpha: 0.10),
                  borderRadius:
                  BorderRadius.circular(s.w(6)),
                ),
                child: Text(
                  '₹${outstandingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: AppColors.accent
                        .withValues(alpha: 0.90),
                    fontFamily: 'Rale-way',
                    fontSize: s.sp(10),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: onChanged,
    );
  }
}

class _DialogButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback onTap;
  final bool isPrimary;
  final AppScaler s;

  const _DialogButton({
    required this.text,
    required this.enabled,
    required this.onTap,
    required this.isPrimary,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.38,
        child: Container(
          height: s.h(47),
          decoration: BoxDecoration(
            color: isPrimary
                ? null
                : Colors.white.withValues(alpha: 0.055),
            gradient: isPrimary
                ? const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accent,
                AppColors.primary,
              ],
            )
                : null,
            borderRadius: BorderRadius.circular(s.w(10)),
            border: Border.all(
              color: isPrimary
                  ? Colors.white.withValues(alpha: 0.10)
                  : Colors.white.withValues(alpha: 0.09),
            ),
            boxShadow: isPrimary && enabled
                ? [
              BoxShadow(
                color: AppColors.primary
                    .withValues(alpha: 0.20),
                blurRadius: 13,
                spreadRadius: 0.5,
              ),
            ]
                : null,
          ),
          child: Center(
            child: Text(
              text,
              style: TextStyle(
                color: isPrimary
                    ? Colors.white
                    : Colors.white.withValues(alpha: 0.72),
                fontFamily: 'Rale-way',
                fontSize: s.sp(14),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}