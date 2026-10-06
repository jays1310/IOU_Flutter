import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/registered_user_model.dart';
import '../../../providers/transaction_provider.dart';

class SettleUpDialog extends StatefulWidget {
  final RegisteredUserModel user;
  final double outstandingAmount;

  const SettleUpDialog({
    super.key,
    required this.user,
    required this.outstandingAmount,
  });

  @override
  State<SettleUpDialog> createState() =>
      _SettleUpDialogState();
}

class _SettleUpDialogState
    extends State<SettleUpDialog> {
  final TextEditingController amountController =
  TextEditingController();

  bool _isSubmitting = false;

  bool get _isSettleEnabled {
    if (_isSubmitting) {
      return false;
    }

    final amount = double.tryParse(
      amountController.text.trim(),
    );

    if (amount == null || amount <= 0) {
      return false;
    }

    return amount <= widget.outstandingAmount;
  }

  @override
  void dispose() {
    amountController.dispose();
    super.dispose();
  }

  Future<void> _handleSettleUp() async {
    if (!_isSettleEnabled) {
      return;
    }

    final amount = double.parse(
      amountController.text.trim(),
    );

    if (amount > widget.outstandingAmount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'You can settle a maximum of '
                '₹${widget.outstandingAmount.toStringAsFixed(2)}.',
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

      await context
          .read<TransactionProvider>()
          .createIndividualSettlement(
        individualUserId: widget.user.id,
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
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final enteredAmount = double.tryParse(
      amountController.text.trim(),
    );

    final exceedsOutstanding =
        enteredAmount != null &&
            enteredAmount >
                widget.outstandingAmount;

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
            maxHeight:
            MediaQuery.of(context).size.height *
                0.82,
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
              borderRadius:
              BorderRadius.circular(s.w(20)),
              border: Border.all(
                color:
                AppColors.primary.withValues(
                  alpha: 0.32,
                ),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(
                    alpha: 0.55,
                  ),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color:
                  AppColors.primary.withValues(
                    alpha: 0.16,
                  ),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius:
              BorderRadius.circular(s.w(20)),
              child: Stack(
                children: [
                  // ---------------------------------------------------
                  // TOP RIGHT PURPLE GLOW
                  // ---------------------------------------------------
                  Positioned(
                    top: -s.h(80),
                    right: -s.w(85),
                    child: Container(
                      width: s.w(190),
                      height: s.w(190),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                        RadialGradient(
                          colors: [
                            AppColors.primary
                                .withValues(
                              alpha: 0.20,
                            ),
                            AppColors.primary
                                .withValues(
                              alpha: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ---------------------------------------------------
                  // BOTTOM LEFT PINK/PURPLE GLOW
                  // ---------------------------------------------------
                  Positioned(
                    bottom: -s.h(90),
                    left: -s.w(100),
                    child: Container(
                      width: s.w(210),
                      height: s.w(210),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient:
                        RadialGradient(
                          colors: [
                            AppColors.accent
                                .withValues(
                              alpha: 0.12,
                            ),
                            AppColors.accent
                                .withValues(
                              alpha: 0.0,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // ---------------------------------------------------
                  // CONTENT
                  // ---------------------------------------------------
                  Padding(
                    padding: EdgeInsets.fromLTRB(
                      s.w(22),
                      s.h(21),
                      s.w(22),
                      s.h(18),
                    ),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize:
                        MainAxisSize.min,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          // -------------------------------------------------
                          // HEADER
                          // -------------------------------------------------
                          _DialogHeader(
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(25),
                          ),

                          // -------------------------------------------------
                          // PAY TO
                          // -------------------------------------------------
                          _FieldLabel(
                            text: 'Pay To',
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(8),
                          ),

                          _UserDisplay(
                            user: widget.user,
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(18),
                          ),

                          // -------------------------------------------------
                          // OUTSTANDING
                          // -------------------------------------------------
                          _FieldLabel(
                            text: 'Outstanding',
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(8),
                          ),

                          _OutstandingDisplay(
                            amount:
                            widget.outstandingAmount,
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(18),
                          ),

                          // -------------------------------------------------
                          // AMOUNT
                          // -------------------------------------------------
                          _FieldLabel(
                            text: 'Amount',
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(8),
                          ),

                          _DialogTextField(
                            controller:
                            amountController,
                            hintText:
                            'Enter settlement amount',
                            keyboardType:
                            const TextInputType
                                .numberWithOptions(
                              decimal: true,
                            ),
                            onChanged: (_) {
                              setState(() {});
                            },
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(7),
                          ),

                          // -------------------------------------------------
                          // MAXIMUM AMOUNT
                          // -------------------------------------------------
                          Padding(
                            padding:
                            EdgeInsets.only(
                              left: s.w(2),
                            ),
                            child: Row(
                              children: [
                                Icon(
                                  Icons
                                      .info_outline_rounded,
                                  size: s.sp(13),
                                  color: exceedsOutstanding
                                      ? Colors.redAccent
                                      : Colors.white
                                      .withValues(
                                    alpha: 0.30,
                                  ),
                                ),
                                SizedBox(
                                  width: s.w(5),
                                ),
                                Text(
                                  'Maximum: ₹${widget.outstandingAmount.toStringAsFixed(2)}',
                                  style: TextStyle(
                                    color:
                                    exceedsOutstanding
                                        ? Colors.redAccent
                                        : Colors.white
                                        .withValues(
                                      alpha:
                                      0.38,
                                    ),
                                    fontFamily:
                                    'Raleway',
                                    fontSize:
                                    s.sp(10),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          if (exceedsOutstanding) ...[
                            SizedBox(
                              height: s.h(5),
                            ),
                            Text(
                              'Settlement amount cannot exceed the outstanding amount.',
                              style: TextStyle(
                                color:
                                Colors.redAccent,
                                fontFamily:
                                'Raleway',
                                fontSize:
                                s.sp(10),
                              ),
                            ),
                          ],

                          SizedBox(
                            height: s.h(27),
                          ),

                          // -------------------------------------------------
                          // BUTTONS
                          // -------------------------------------------------
                          Row(
                            children: [
                              Expanded(
                                child:
                                _DialogButton(
                                  text: 'Cancel',
                                  enabled:
                                  !_isSubmitting,
                                  isPrimary: false,
                                  onTap: () {
                                    Navigator.of(
                                      context,
                                    ).pop(false);
                                  },
                                  s: s,
                                ),
                              ),

                              SizedBox(
                                width: s.w(11),
                              ),

                              Expanded(
                                child:
                                _DialogButton(
                                  text: _isSubmitting
                                      ? 'Settling...'
                                      : 'Settle Up',
                                  enabled:
                                  _isSettleEnabled,
                                  isPrimary: true,
                                  onTap:
                                  _handleSettleUp,
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
}

// =====================================================================
// DIALOG HEADER
// =====================================================================

class _DialogHeader extends StatelessWidget {
  final AppScaler s;

  const _DialogHeader({
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
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
                color:
                AppColors.primary.withValues(
                  alpha: 0.25,
                ),
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

        SizedBox(
          width: s.w(12),
        ),

        Expanded(
          child: Column(
            crossAxisAlignment:
            CrossAxisAlignment.start,
            children: [
              Text(
                'Settle Up',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(23),
                  fontWeight: FontWeight.w600,
                ),
              ),

              SizedBox(
                height: s.h(2),
              ),

              Text(
                'Clear your outstanding balance',
                style: TextStyle(
                  color:
                  Colors.white.withValues(
                    alpha: 0.45,
                  ),
                  fontFamily: 'Raleway',
                  fontSize: s.sp(11),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// =====================================================================
// FIELD LABEL
// =====================================================================

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
        color:
        Colors.white.withValues(alpha: 0.76),
        fontFamily: 'Raleway',
        fontSize: s.sp(13),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

// =====================================================================
// USER DISPLAY
// =====================================================================

class _UserDisplay extends StatelessWidget {
  final RegisteredUserModel user;
  final AppScaler s;

  const _UserDisplay({
    required this.user,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    final initials =
    user.username.isNotEmpty
        ? user.username
        .trim()
        .split(' ')
        .where(
          (part) =>
      part.isNotEmpty,
    )
        .take(2)
        .map(
          (part) =>
          part[0].toUpperCase(),
    )
        .join()
        : '?';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: s.w(12),
        vertical: s.h(10),
      ),
      decoration: BoxDecoration(
        color:
        Colors.white.withValues(alpha: 0.045),
        borderRadius:
        BorderRadius.circular(s.w(10)),
        border: Border.all(
          color:
          Colors.white.withValues(alpha: 0.09),
        ),
      ),
      child: Row(
        children: [
          // Gradient Avatar
          Container(
            width: s.w(40),
            height: s.w(40),
            padding: EdgeInsets.all(
              s.w(1.8),
            ),
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
                  color:
                  AppColors.primary.withValues(
                    alpha: 0.20,
                  ),
                  blurRadius: 10,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.background,
              ),
              alignment: Alignment.center,
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          SizedBox(
            width: s.w(11),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Paying to',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.35),
                    fontFamily: 'Raleway',
                    fontSize: s.sp(9),
                  ),
                ),

                SizedBox(
                  height: s.h(2),
                ),

                Text(
                  user.username,
                  overflow:
                  TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: s.sp(14),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),

          Icon(
            Icons.arrow_forward_ios_rounded,
            color:
            AppColors.accent.withValues(
              alpha: 0.60,
            ),
            size: s.sp(14),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// OUTSTANDING DISPLAY
// =====================================================================

class _OutstandingDisplay
    extends StatelessWidget {
  final double amount;
  final AppScaler s;

  const _OutstandingDisplay({
    required this.amount,
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
        color:
        AppColors.primary.withValues(
          alpha: 0.08,
        ),
        borderRadius:
        BorderRadius.circular(s.w(10)),
        border: Border.all(
          color:
          AppColors.primary.withValues(
            alpha: 0.25,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color:
            AppColors.primary.withValues(
              alpha: 0.06,
            ),
            blurRadius: 12,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: s.w(32),
            height: s.w(32),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color:
              AppColors.primary.withValues(
                alpha: 0.10,
              ),
            ),
            child: Icon(
              Icons.account_balance_wallet_outlined,
              color:
              AppColors.accent.withValues(
                alpha: 0.85,
              ),
              size: s.sp(17),
            ),
          ),

          SizedBox(
            width: s.w(10),
          ),

          Expanded(
            child: Column(
              crossAxisAlignment:
              CrossAxisAlignment.start,
              children: [
                Text(
                  'Amount Due',
                  style: TextStyle(
                    color: Colors.white
                        .withValues(alpha: 0.38),
                    fontFamily: 'Raleway',
                    fontSize: s.sp(9),
                  ),
                ),

                SizedBox(
                  height: s.h(2),
                ),

                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: s.sp(18),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================================
// TEXT FIELD
// =====================================================================

class _DialogTextField
    extends StatelessWidget {
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
    return SizedBox(
      height: s.h(46),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        cursorColor: AppColors.primary,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Raleway',
          fontSize: s.sp(14),
        ),
        decoration: InputDecoration(
          prefixText: '₹ ',
          prefixStyle: TextStyle(
            color:
            AppColors.accent.withValues(
              alpha: 0.85,
            ),
            fontFamily: 'Raleway',
            fontSize: s.sp(16),
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color:
            Colors.white.withValues(
              alpha: 0.34,
            ),
            fontFamily: 'Raleway',
            fontSize: s.sp(13),
          ),
          filled: true,
          fillColor:
          Colors.white.withValues(alpha: 0.045),
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: s.w(14),
            vertical: s.h(13),
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(s.w(10)),
            borderSide: BorderSide(
              color:
              Colors.white.withValues(
                alpha: 0.09,
              ),
            ),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(s.w(10)),
            borderSide: BorderSide(
              color:
              Colors.white.withValues(
                alpha: 0.09,
              ),
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(s.w(10)),
            borderSide: BorderSide(
              color:
              AppColors.primary.withValues(
                alpha: 0.85,
              ),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

// =====================================================================
// BUTTON
// =====================================================================

class _DialogButton
    extends StatelessWidget {
  final String text;
  final bool enabled;
  final bool isPrimary;
  final VoidCallback onTap;
  final AppScaler s;

  const _DialogButton({
    required this.text,
    required this.enabled,
    required this.isPrimary,
    required this.onTap,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: enabled ? onTap : null,
      child: AnimatedOpacity(
        duration:
        const Duration(milliseconds: 150),
        opacity: enabled ? 1.0 : 0.38,
        child: Container(
          height: s.h(47),
          decoration: BoxDecoration(
            color: isPrimary
                ? null
                : Colors.white.withValues(
              alpha: 0.055,
            ),
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
            borderRadius:
            BorderRadius.circular(s.w(10)),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.09,
              ),
            ),
            boxShadow:
            isPrimary && enabled
                ? [
              BoxShadow(
                color: AppColors.primary
                    .withValues(
                  alpha: 0.20,
                ),
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
                    : Colors.white.withValues(
                  alpha: 0.72,
                ),
                fontFamily: 'Raleway',
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