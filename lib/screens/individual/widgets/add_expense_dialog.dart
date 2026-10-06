import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../core/utils/app_toast.dart';
import '../../../core/utils/split_calculator.dart';
import '../../../models/registered_user_model.dart';
import '../../../providers/transaction_provider.dart';

class AddExpenseDialog extends StatefulWidget {
  final RegisteredUserModel user;

  const AddExpenseDialog({
    super.key,
    required this.user,
  });

  @override
  State<AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<AddExpenseDialog> {
  final TextEditingController descriptionController =
  TextEditingController();

  final TextEditingController amountController =
  TextEditingController();

  final ScrollController _dialogScrollController =
  ScrollController();

  String? selectedPaidBy;
  String? selectedSplitType;

  final Set<String> selectedParticipantIds = {};

  Map<String, double> calculatedShares = {};
  Map<String, double> exactAmounts = {};
  Map<String, double> enteredPercentages = {};

  bool _isSubmitting = false;

  static const String _currentUser = 'current_user';
  static const String _individualUser = 'individual_user';

  double? get _amount {
    return double.tryParse(
      amountController.text.trim(),
    );
  }

  String _actualMarkerForParticipant(String id) {
    if (id == _currentUser) {
      return _currentUser;
    }

    return _individualUser;
  }

  bool _areAllParticipantSharesValid() {
    if (selectedParticipantIds.length != 2) {
      return false;
    }

    for (final participantId in selectedParticipantIds) {
      final share = calculatedShares[participantId];

      if (share == null || share <= 0) {
        return false;
      }
    }

    return true;
  }

  bool get _isAddEnabled {
    if (_isSubmitting) {
      return false;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return false;
    }

    if (selectedPaidBy == null) {
      return false;
    }

    if (selectedParticipantIds.isEmpty) {
      return false;
    }

    if (selectedParticipantIds.length == 1 &&
        selectedParticipantIds.first == selectedPaidBy) {
      return false;
    }

    if (selectedParticipantIds.length == 1) {
      return true;
    }

    if (selectedParticipantIds.length != 2 ||
        selectedSplitType == null) {
      return false;
    }

    if (selectedSplitType == 'Equal') {
      return calculatedShares.isNotEmpty &&
          SplitCalculator.isExactSplitValid(
            amount: amount,
            shares: calculatedShares,
          ) &&
          _areAllParticipantSharesValid();
    }

    if (selectedSplitType == 'Exact') {
      if (calculatedShares.isEmpty) {
        return false;
      }

      if (!SplitCalculator.isExactSplitValid(
        amount: amount,
        shares: calculatedShares,
      )) {
        return false;
      }

      return _areAllParticipantSharesValid();
    }

    if (selectedSplitType == 'Percentage') {
      if (calculatedShares.isEmpty) {
        return false;
      }

      if (!SplitCalculator.isPercentageSplitValid(
        percentages: enteredPercentages,
      )) {
        return false;
      }

      return _areAllParticipantSharesValid();
    }

    return false;
  }

  void _calculateEqualShares() {
    calculatedShares = {};

    if (selectedSplitType != 'Equal') {
      return;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return;
    }

    if (selectedParticipantIds.length != 2) {
      return;
    }

    calculatedShares = SplitCalculator.calculateEqual(
      amount: amount,
      participantIds: selectedParticipantIds.toList(),
    );
  }

  void _calculateExactShares() {
    calculatedShares = {};

    if (selectedSplitType != 'Exact') {
      return;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return;
    }

    if (selectedParticipantIds.length != 2) {
      return;
    }

    calculatedShares = SplitCalculator.calculateExact(
      amount: amount,
      participantIds: selectedParticipantIds.toList(),
      enteredAmounts: exactAmounts,
    );
  }

  void _calculatePercentageShares() {
    calculatedShares = {};

    if (selectedSplitType != 'Percentage') {
      return;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return;
    }

    if (selectedParticipantIds.length != 2) {
      return;
    }

    calculatedShares = SplitCalculator.calculatePercentage(
      amount: amount,
      participantIds: selectedParticipantIds.toList(),
      enteredPercentages: enteredPercentages,
    );
  }

  void _handleSplitTypeChanged(String? value) {
    if (value == null) {
      return;
    }

    setState(() {
      selectedSplitType = value;

      calculatedShares = {};
      exactAmounts = {};
      enteredPercentages = {};

      if (value == 'Equal') {
        _calculateEqualShares();
      }
    });
  }

  void _toggleParticipant(String id) {
    setState(() {
      if (selectedParticipantIds.contains(id)) {
        selectedParticipantIds.remove(id);
      } else {
        selectedParticipantIds.add(id);
      }

      calculatedShares = {};
      exactAmounts = {};
      enteredPercentages = {};

      if (selectedParticipantIds.length < 2) {
        selectedSplitType = null;
        return;
      }

      if (selectedSplitType == 'Equal') {
        _calculateEqualShares();
      }
    });
  }

  Future<void> _handleAddExpense() async {
    if (!_isAddEnabled) {
      return;
    }

    final amount = _amount;

    if (amount == null || selectedPaidBy == null) {
      return;
    }

    final participantIds = selectedParticipantIds.toList();

    String splitType;
    List<Map<String, dynamic>> splitDetails;

    if (participantIds.length == 1) {
      splitType = 'exact';

      splitDetails = [
        {
          'user_id':
          _actualMarkerForParticipant(participantIds.first),
          'value': amount,
        },
      ];
    } else if (selectedSplitType == 'Equal') {
      splitType = 'equal';

      splitDetails = participantIds.map((participantId) {
        return {
          'user_id':
          _actualMarkerForParticipant(participantId),
        };
      }).toList();
    } else if (selectedSplitType == 'Exact') {
      splitType = 'exact';

      splitDetails = participantIds.map((participantId) {
        return {
          'user_id':
          _actualMarkerForParticipant(participantId),
          'value': calculatedShares[participantId] ?? 0,
        };
      }).toList();
    } else if (selectedSplitType == 'Percentage') {
      splitType = 'percentage';

      splitDetails = participantIds.map((participantId) {
        return {
          'user_id':
          _actualMarkerForParticipant(participantId),
          'value': enteredPercentages[participantId] ?? 0,
        };
      }).toList();
    } else {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context
          .read<TransactionProvider>()
          .createIndividualExpense(
        individualUserId: widget.user.id,
        description: descriptionController.text.trim(),
        amount: amount,
        paidBy: selectedPaidBy!,
        splitType: splitType,
        splitDetails: splitDetails,
      );

      if (!mounted) {
        return;
      }

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        _isSubmitting = false;
      });

      AppToast.error(
        context,
        e.toString().replaceFirst('Exception: ', ''),
      );
    }
  }

  @override
  void dispose() {
    descriptionController.dispose();
    amountController.dispose();
    _dialogScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);
    final keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom;

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
            MediaQuery.of(context).size.height * 0.88,
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
                color:
                AppColors.primary.withValues(alpha: 0.32),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.55),
                  blurRadius: 26,
                  offset: const Offset(0, 10),
                ),
                BoxShadow(
                  color:
                  AppColors.primary.withValues(alpha: 0.16),
                  blurRadius: 24,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(s.w(20)),
              child: Stack(
                children: [
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
                            AppColors.primary
                                .withValues(alpha: 0.20),
                            AppColors.primary
                                .withValues(alpha: 0.0),
                          ],
                        ),
                      ),
                    ),
                  ),

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
                            AppColors.accent
                                .withValues(alpha: 0.12),
                            AppColors.accent
                                .withValues(alpha: 0.0),
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
                      controller: _dialogScrollController,
                      keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.manual,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment:
                        CrossAxisAlignment.start,
                        children: [
                          _DialogHeader(s: s),

                          SizedBox(height: s.h(25)),

                          _FieldLabel(
                            text: 'Description',
                            s: s,
                          ),

                          SizedBox(height: s.h(8)),

                          _DialogTextField(
                            controller: descriptionController,
                            hintText:
                            'What was this expense for?',
                            keyboardType: TextInputType.text,
                            s: s,
                          ),

                          SizedBox(height: s.h(18)),

                          _FieldLabel(
                            text: 'Amount',
                            s: s,
                          ),

                          SizedBox(height: s.h(8)),

                          _DialogTextField(
                            controller: amountController,
                            hintText: 'Enter amount',
                            keyboardType:
                            const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            prefixText: '₹',
                            onChanged: (_) {
                              setState(() {
                                if (selectedSplitType ==
                                    'Equal') {
                                  _calculateEqualShares();
                                } else if (selectedSplitType ==
                                    'Exact') {
                                  _calculateExactShares();
                                } else if (selectedSplitType ==
                                    'Percentage') {
                                  _calculatePercentageShares();
                                }
                              });
                            },
                            s: s,
                          ),

                          SizedBox(height: s.h(18)),

                          _FieldLabel(
                            text: 'Paid By',
                            s: s,
                          ),

                          SizedBox(height: s.h(8)),

                          _PersonDropdown(
                            value: selectedPaidBy,
                            hintText: 'Select who paid',
                            user: widget.user,
                            onChanged: (value) {
                              setState(() {
                                selectedPaidBy = value;
                              });
                            },
                            s: s,
                          ),

                          SizedBox(height: s.h(18)),

                          _FieldLabel(
                            text: 'Split Between',
                            s: s,
                          ),

                          SizedBox(height: s.h(8)),

                          _PersonMultiSelect(
                            selectedValues:
                            selectedParticipantIds,
                            user: widget.user,
                            onChanged: _toggleParticipant,
                            s: s,
                          ),

                          if (selectedParticipantIds.length ==
                              2) ...[
                            SizedBox(height: s.h(18)),

                            _FieldLabel(
                              text: 'Split Type',
                              s: s,
                            ),

                            SizedBox(height: s.h(8)),

                            _OptionDropdown(
                              value: selectedSplitType,
                              hintText: 'Select split type',
                              items: const [
                                'Equal',
                                'Exact',
                                'Percentage',
                              ],
                              onChanged:
                              _handleSplitTypeChanged,
                              s: s,
                            ),

                            if (selectedSplitType == 'Equal' &&
                                calculatedShares.isNotEmpty) ...[
                              SizedBox(height: s.h(14)),
                              _SharePreview(
                                user: widget.user,
                                shares: calculatedShares,
                                s: s,
                              ),
                            ],

                            if (selectedSplitType == 'Exact') ...[
                              SizedBox(height: s.h(14)),
                              _ExactSplitInput(
                                user: widget.user,
                                totalAmount: _amount ?? 0,
                                initialAmounts: exactAmounts,
                                onChanged: (values) {
                                  setState(() {
                                    exactAmounts = values;
                                    _calculateExactShares();
                                  });
                                },
                                s: s,
                              ),
                            ],

                            if (selectedSplitType ==
                                'Percentage') ...[
                              SizedBox(height: s.h(14)),
                              _PercentageSplitInput(
                                user: widget.user,
                                initialPercentages:
                                enteredPercentages,
                                onChanged: (values) {
                                  setState(() {
                                    enteredPercentages = values;
                                    _calculatePercentageShares();
                                  });
                                },
                                s: s,
                              ),
                              if (calculatedShares.isNotEmpty) ...[
                                SizedBox(height: s.h(10)),
                                _SharePreview(
                                  user: widget.user,
                                  shares: calculatedShares,
                                  s: s,
                                ),
                              ],
                            ],
                          ],

                          SizedBox(height: s.h(27)),

                          Row(
                            children: [
                              Expanded(
                                child: _DialogButton(
                                  text: 'Cancel',
                                  enabled: !_isSubmitting,
                                  isPrimary: false,
                                  onTap: () {
                                    Navigator.pop(context);
                                  },
                                  s: s,
                                ),
                              ),

                              SizedBox(width: s.w(11)),

                              Expanded(
                                child: _DialogButton(
                                  text: _isSubmitting
                                      ? 'Adding...'
                                      : 'Add Expense',
                                  enabled: _isAddEnabled,
                                  isPrimary: true,
                                  onTap: _handleAddExpense,
                                  s: s,
                                ),
                              ),
                            ],
                          ),

                          if (keyboardHeight > 0)
                            SizedBox(
                              height:
                              keyboardHeight + s.h(80),
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
                AppColors.primary.withValues(alpha: 0.25),
                blurRadius: 14,
                spreadRadius: 1,
              ),
            ],
          ),
          child: Icon(
            Icons.receipt_long_rounded,
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
                'Add Expense',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(23),
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: s.h(2)),
              Text(
                'Split this expense with your friend',
                style: TextStyle(
                  color:
                  Colors.white.withValues(alpha: 0.45),
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
        fontFamily: 'Raleway',
        fontSize: s.sp(13),
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _DialogTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType keyboardType;
  final ValueChanged<String>? onChanged;
  final String? prefixText;
  final AppScaler s;

  const _DialogTextField({
    required this.controller,
    required this.hintText,
    required this.keyboardType,
    required this.s,
    this.onChanged,
    this.prefixText,
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
          prefixText: prefixText,
          prefixStyle: TextStyle(
            color:
            AppColors.accent.withValues(alpha: 0.85),
            fontFamily: 'Raleway',
            fontSize: s.sp(17),
            fontWeight: FontWeight.w600,
          ),
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.34),
            fontFamily: 'Raleway',
            fontSize: s.sp(13),
          ),
          filled: true,
          fillColor:
          Colors.white.withValues(alpha: 0.045),
          contentPadding: EdgeInsets.symmetric(
            horizontal: s.w(14),
            vertical: s.h(13),
          ),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(s.w(10)),
            borderSide: BorderSide(
              color:
              Colors.white.withValues(alpha: 0.09),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(s.w(10)),
            borderSide: BorderSide(
              color:
              Colors.white.withValues(alpha: 0.09),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(s.w(10)),
            borderSide: BorderSide(
              color:
              AppColors.primary.withValues(alpha: 0.85),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

class _PersonDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final RegisteredUserModel user;
  final ValueChanged<String?> onChanged;
  final AppScaler s;

  const _PersonDropdown({
    required this.value,
    required this.hintText,
    required this.user,
    required this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: s.h(46),
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
      padding: EdgeInsets.symmetric(
        horizontal: s.w(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF160A2D),
          borderRadius:
          BorderRadius.circular(s.w(12)),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color:
            AppColors.accent.withValues(alpha: 0.80),
            size: s.sp(21),
          ),
          hint: Text(
            hintText,
            style: TextStyle(
              color:
              Colors.white.withValues(alpha: 0.34),
              fontFamily: 'Raleway',
              fontSize: s.sp(13),
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Raleway',
            fontSize: s.sp(14),
          ),
          items: [
            DropdownMenuItem<String>(
              value: 'current_user',
              child: Text(
                'You',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(14),
                ),
              ),
            ),
            DropdownMenuItem<String>(
              value: 'individual_user',
              child: Text(
                user.username,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(14),
                ),
              ),
            ),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _PersonMultiSelect extends StatelessWidget {
  final Set<String> selectedValues;
  final RegisteredUserModel user;
  final ValueChanged<String> onChanged;
  final AppScaler s;

  const _PersonMultiSelect({
    required this.selectedValues,
    required this.user,
    required this.onChanged,
    required this.s,
  });

  Widget _personOption({
    required String id,
    required String name,
  }) {
    final selected =
    selectedValues.contains(id);

    return GestureDetector(
      onTap: () => onChanged(id),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(
          bottom: s.h(8),
        ),
        padding: EdgeInsets.symmetric(
          horizontal: s.w(12),
          vertical: s.h(10),
        ),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.primary
              .withValues(alpha: 0.12)
              : Colors.white
              .withValues(alpha: 0.045),
          borderRadius:
          BorderRadius.circular(s.w(10)),
          border: Border.all(
            color: selected
                ? AppColors.primary
                .withValues(alpha: 0.70)
                : Colors.white
                .withValues(alpha: 0.09),
          ),
          boxShadow: selected
              ? [
            BoxShadow(
              color: AppColors.primary
                  .withValues(alpha: 0.10),
              blurRadius: 10,
            ),
          ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: s.w(21),
              height: s.w(21),
              decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(s.w(6)),
                gradient: selected
                    ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accent,
                    AppColors.primary,
                  ],
                )
                    : null,
                color: selected
                    ? null
                    : Colors.transparent,
                border: Border.all(
                  color: selected
                      ? AppColors.primary
                      : Colors.white38,
                  width: 1.4,
                ),
              ),
              child: selected
                  ? Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: s.w(14),
              )
                  : null,
            ),
            SizedBox(width: s.w(10)),
            Expanded(
              child: Text(
                name,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedText = selectedValues.isEmpty
        ? 'Select people'
        : selectedValues
        .map(
          (id) => id == 'current_user'
          ? 'You'
          : user.username,
    )
        .join(', ');

    return Column(
      crossAxisAlignment:
      CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(
            horizontal: s.w(12),
            vertical: s.h(12),
          ),
          decoration: BoxDecoration(
            color:
            Colors.white.withValues(alpha: 0.045),
            borderRadius:
            BorderRadius.circular(s.w(10)),
            border: Border.all(
              color: selectedValues.isEmpty
                  ? Colors.white
                  .withValues(alpha: 0.09)
                  : AppColors.primary
                  .withValues(alpha: 0.55),
            ),
          ),
          child: Text(
            selectedText,
            style: TextStyle(
              color: selectedValues.isEmpty
                  ? Colors.white
                  .withValues(alpha: 0.34)
                  : Colors.white,
              fontFamily: 'Raleway',
              fontSize: s.sp(14),
            ),
          ),
        ),

        SizedBox(height: s.h(8)),

        _personOption(
          id: 'current_user',
          name: 'You',
        ),

        _personOption(
          id: 'individual_user',
          name: user.username,
        ),
      ],
    );
  }
}

class _OptionDropdown extends StatelessWidget {
  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final AppScaler s;

  const _OptionDropdown({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: s.h(46),
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
      padding: EdgeInsets.symmetric(
        horizontal: s.w(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF160A2D),
          borderRadius:
          BorderRadius.circular(s.w(12)),
          icon: Icon(
            Icons.keyboard_arrow_down_rounded,
            color:
            AppColors.accent.withValues(alpha: 0.80),
            size: s.sp(21),
          ),
          hint: Text(
            hintText,
            style: TextStyle(
              color:
              Colors.white.withValues(alpha: 0.34),
              fontFamily: 'Raleway',
              fontSize: s.sp(13),
            ),
          ),
          style: TextStyle(
            color: Colors.white,
            fontFamily: 'Raleway',
            fontSize: s.sp(14),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(14),
                ),
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}

class _ExactSplitInput extends StatelessWidget {
  final RegisteredUserModel user;
  final double totalAmount;
  final Map<String, double> initialAmounts;
  final ValueChanged<Map<String, double>> onChanged;
  final AppScaler s;

  const _ExactSplitInput({
    required this.user,
    required this.totalAmount,
    required this.initialAmounts,
    required this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return _TwoPersonInput(
      title: 'Enter exact amounts',
      firstLabel: 'You',
      secondLabel: user.username,
      totalAmount: totalAmount,
      initialValues: initialAmounts,
      onChanged: onChanged,
      s: s,
    );
  }
}

class _PercentageSplitInput extends StatelessWidget {
  final RegisteredUserModel user;
  final Map<String, double> initialPercentages;
  final ValueChanged<Map<String, double>> onChanged;
  final AppScaler s;

  const _PercentageSplitInput({
    required this.user,
    required this.initialPercentages,
    required this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return _TwoPersonInput(
      title: 'Enter percentages',
      firstLabel: 'You',
      secondLabel: user.username,
      initialValues: initialPercentages,
      suffix: '%',
      onChanged: onChanged,
      s: s,
    );
  }
}

class _TwoPersonInput extends StatefulWidget {
  final String title;
  final String firstLabel;
  final String secondLabel;
  final double? totalAmount;
  final Map<String, double> initialValues;
  final String suffix;
  final ValueChanged<Map<String, double>> onChanged;
  final AppScaler s;

  const _TwoPersonInput({
    required this.title,
    required this.firstLabel,
    required this.secondLabel,
    this.totalAmount,
    required this.initialValues,
    this.suffix = '',
    required this.onChanged,
    required this.s,
  });

  @override
  State<_TwoPersonInput> createState() =>
      _TwoPersonInputState();
}

class _TwoPersonInputState
    extends State<_TwoPersonInput> {
  late final TextEditingController _firstController;

  final FocusNode _firstFocusNode =
  FocusNode();

  final GlobalKey _firstFieldKey =
  GlobalKey();

  double _remainingValue = 0;

  bool _hasExceeded = false;
  bool _hasZeroRemainingShare = false;
  bool _hasInvalidInput = false;

  bool get _isPercentage =>
      widget.suffix == '%';

  @override
  void initState() {
    super.initState();

    _firstController =
        TextEditingController(
          text: _formatInitial(
            widget.initialValues['current_user'],
          ),
        );

    _firstController.addListener(
      _handleInputChanged,
    );

    _firstFocusNode.addListener(() {
      if (_firstFocusNode.hasFocus) {
        _scrollFieldIntoView();
      }
    });

    _calculateValue(
      notifyParent: false,
    );

    WidgetsBinding.instance.addPostFrameCallback(
          (_) {
        if (mounted) {
          _notifyParent();
        }
      },
    );
  }

  @override
  void didUpdateWidget(
      covariant _TwoPersonInput oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.totalAmount !=
        widget.totalAmount) {
      _calculateValue(
        notifyParent: true,
      );
    }
  }

  String _formatInitial(double? value) {
    if (value == null) {
      return '';
    }

    return value
        .toStringAsFixed(2)
        .replaceFirst(
      RegExp(r'\.?0+$'),
      '',
    );
  }

  void _scrollFieldIntoView() {
    Future.delayed(
      const Duration(milliseconds: 300),
          () {
        if (!mounted ||
            !_firstFocusNode.hasFocus) {
          return;
        }

        final fieldContext =
            _firstFieldKey.currentContext;

        if (fieldContext == null || !fieldContext.mounted) {
          return;
        }

        Scrollable.ensureVisible(
          fieldContext,
          duration:
          const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: 0.25,
        );
      },
    );
  }

  void _handleInputChanged() {
    _calculateValue(
      notifyParent: true,
    );
  }

  void _calculateValue({
    required bool notifyParent,
  }) {
    final enteredText =
    _firstController.text.trim();

    final entered =
    double.tryParse(enteredText);

    final limit = _isPercentage
        ? 100.0
        : (widget.totalAmount ?? 0);

    _hasInvalidInput =
        enteredText.isNotEmpty &&
            (entered == null ||
                entered < 0);

    if (entered == null ||
        entered < 0) {
      _remainingValue = limit;
      _hasExceeded = false;
      _hasZeroRemainingShare = false;
    } else {
      _remainingValue =
          limit - entered;

      _hasExceeded =
          _remainingValue < 0;

      _hasZeroRemainingShare =
          !_hasExceeded &&
              _remainingValue == 0;
    }

    if (mounted) {
      setState(() {});
    }

    if (notifyParent) {
      _notifyParent();
    }
  }

  void _notifyParent() {
    final entered =
    double.tryParse(
      _firstController.text.trim(),
    );

    final limit = _isPercentage
        ? 100.0
        : (widget.totalAmount ?? 0);

    final firstValue =
    entered != null &&
        entered >= 0
        ? entered
        : 0.0;

    final secondValue =
    (limit - firstValue) >= 0
        ? limit - firstValue
        : 0.0;

    widget.onChanged({
      'current_user': firstValue,
      'individual_user': secondValue,
    });
  }

  String _formatValue(double value) {
    return value.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _firstController.removeListener(
      _handleInputChanged,
    );
    _firstController.dispose();
    _firstFocusNode.dispose();
    super.dispose();
  }

  Widget _buildEditableInput() {
    final isInvalid =
        _hasExceeded ||
            _hasInvalidInput ||
            _hasZeroRemainingShare;

    return SizedBox(
      width: double.infinity,
      height: widget.s.h(44),
      child: TextField(
        key: _firstFieldKey,
        controller: _firstController,
        focusNode: _firstFocusNode,
        keyboardType:
        const TextInputType.numberWithOptions(
          decimal: true,
        ),
        textAlign: TextAlign.right,
        style: TextStyle(
          color: isInvalid
              ? Colors.redAccent
              : Colors.white,
          fontFamily: 'Raleway',
          fontSize: widget.s.sp(13),
        ),
        decoration: InputDecoration(
          prefixText:
          _isPercentage ? null : '₹ ',
          prefixStyle: TextStyle(
            color: isInvalid
                ? Colors.redAccent
                : Colors.white54,
            fontFamily: 'Raleway',
            fontSize: widget.s.sp(13),
          ),
          suffixText:
          _isPercentage ? '%' : null,
          suffixStyle: TextStyle(
            color: isInvalid
                ? Colors.redAccent
                : Colors.white54,
            fontFamily: 'Raleway',
            fontSize: widget.s.sp(13),
          ),
          hintText: '0.00',
          hintStyle: TextStyle(
            color: isInvalid
                ? Colors.redAccent
                .withValues(alpha: 0.55)
                : Colors.white30,
            fontFamily: 'Raleway',
            fontSize: widget.s.sp(13),
          ),
          contentPadding:
          EdgeInsets.symmetric(
            horizontal: widget.s.w(10),
            vertical: widget.s.h(7),
          ),
          filled: true,
          fillColor:
          Colors.white.withValues(alpha: 0.045),
          border: OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(safeRadius(widget.s)),
            borderSide: BorderSide(
              color: isInvalid
                  ? Colors.redAccent
                  : Colors.white
                  .withValues(alpha: 0.09),
            ),
          ),
          enabledBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(safeRadius(widget.s)),
            borderSide: BorderSide(
              color: isInvalid
                  ? Colors.redAccent
                  : Colors.white
                  .withValues(alpha: 0.09),
            ),
          ),
          focusedBorder:
          OutlineInputBorder(
            borderRadius:
            BorderRadius.circular(safeRadius(widget.s)),
            borderSide: BorderSide(
              color: isInvalid
                  ? Colors.redAccent
                  : AppColors.primary
                  .withValues(alpha: 0.85),
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }

  double safeRadius(AppScaler s) {
    return s.w(9);
  }

  Widget _buildCalculatedInput() {
    final isInvalid =
        _hasExceeded ||
            _hasZeroRemainingShare;

    final value = _remainingValue < 0
        ? 0
        : _remainingValue;

    return Container(
      width: double.infinity,
      height: widget.s.h(44),
      alignment: Alignment.centerRight,
      padding: EdgeInsets.symmetric(
        horizontal: widget.s.w(10),
      ),
      decoration: BoxDecoration(
        color:
        Colors.white.withValues(alpha: 0.045),
        borderRadius:
        BorderRadius.circular(
          widget.s.w(9),
        ),
        border: Border.all(
          color: isInvalid
              ? Colors.redAccent
              : AppColors.primary
              .withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        _isPercentage
            ? '${_formatValue(value.toDouble())}%'
            : '₹${_formatValue(value.toDouble())}',
        style: TextStyle(
          color: isInvalid
              ? Colors.redAccent
              : Colors.white,
          fontFamily: 'Raleway',
          fontSize: widget.s.sp(13),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final displayedRemaining =
    _hasExceeded
        ? _remainingValue.abs()
        : 0.0;

    final showError =
        _hasExceeded ||
            _hasInvalidInput ||
            _hasZeroRemainingShare;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        widget.s.w(12),
      ),
      decoration: BoxDecoration(
        color:
        Colors.white.withValues(alpha: 0.045),
        borderRadius:
        BorderRadius.circular(
          widget.s.w(12),
        ),
        border: Border.all(
          color:
          AppColors.primary.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            widget.title,
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontSize: widget.s.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(
            height: widget.s.h(10),
          ),

          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.firstLabel,
                      style: TextStyle(
                        color: showError
                            ? Colors.redAccent
                            : Colors.white70,
                        fontFamily: 'Raleway',
                        fontSize:
                        widget.s.sp(12),
                      ),
                    ),

                    SizedBox(
                      height: widget.s.h(6),
                    ),

                    _buildEditableInput(),
                  ],
                ),
              ),

              SizedBox(
                width: widget.s.w(10),
              ),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.secondLabel,
                      style: TextStyle(
                        color:
                        _hasExceeded ||
                            _hasZeroRemainingShare
                            ? Colors.redAccent
                            : Colors.white70,
                        fontFamily: 'Raleway',
                        fontSize:
                        widget.s.sp(12),
                      ),
                    ),

                    SizedBox(
                      height: widget.s.h(6),
                    ),

                    _buildCalculatedInput(),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(
            height: widget.s.h(10),
          ),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _hasExceeded
                    ? 'Exceeded'
                    : 'Remaining',
                style: TextStyle(
                  color: showError
                      ? Colors.redAccent
                      : Colors.white54,
                  fontFamily: 'Raleway',
                  fontSize:
                  widget.s.sp(12),
                ),
              ),

              Text(
                _isPercentage
                    ? '${_formatValue(displayedRemaining)}%'
                    : '₹${_formatValue(displayedRemaining)}',
                style: TextStyle(
                  color: showError
                      ? Colors.redAccent
                      : Colors.white,
                  fontFamily: 'Raleway',
                  fontSize:
                  widget.s.sp(12),
                  fontWeight:
                  FontWeight.w600,
                ),
              ),
            ],
          ),

          if (_hasExceeded) ...[
            SizedBox(
              height: widget.s.h(6),
            ),
            Text(
              _isPercentage
                  ? 'Entered percentages exceed 100%.'
                  : 'Entered amounts exceed the total expense.',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Raleway',
                fontSize:
                widget.s.sp(11),
              ),
            ),
          ] else if (_hasInvalidInput ||
              _hasZeroRemainingShare) ...[
            SizedBox(
              height: widget.s.h(6),
            ),
            Text(
              'This member has no remaining share.',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Raleway',
                fontSize:
                widget.s.sp(11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _SharePreview extends StatelessWidget {
  final RegisteredUserModel user;
  final Map<String, double> shares;
  final AppScaler s;

  const _SharePreview({
    required this.user,
    required this.shares,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    if (shares.isEmpty) {
      return const SizedBox.shrink();
    }

    final youShare =
        shares['current_user'] ?? 0;

    final individualShare =
        shares['individual_user'] ?? 0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        s.w(12),
      ),
      decoration: BoxDecoration(
        color:
        Colors.white.withValues(alpha: 0.045),
        borderRadius:
        BorderRadius.circular(s.w(12)),
        border: Border.all(
          color:
          AppColors.primary.withValues(
            alpha: 0.18,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: s.w(28),
                height: s.w(28),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.primary
                      .withValues(alpha: 0.10),
                ),
                child: Icon(
                  Icons.pie_chart_outline_rounded,
                  color: AppColors.accent
                      .withValues(alpha: 0.85),
                  size: s.sp(15),
                ),
              ),

              SizedBox(width: s.w(8)),

              Text(
                'Calculated Shares',
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(13),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          SizedBox(height: s.h(12)),

          _buildRow(
            'You',
            youShare,
          ),

          SizedBox(height: s.h(9)),

          _buildRow(
            user.username,
            individualShare,
          ),
        ],
      ),
    );
  }

  Widget _buildRow(
      String name,
      double share,
      ) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: s.w(9),
        vertical: s.h(7),
      ),
      decoration: BoxDecoration(
        color:
        Colors.white.withValues(alpha: 0.025),
        borderRadius:
        BorderRadius.circular(s.w(8)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              name,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.white70,
                fontFamily: 'Raleway',
                fontSize: s.sp(13),
              ),
            ),
          ),

          Text(
            '₹${share.toStringAsFixed(2)}',
            style: TextStyle(
              color: AppColors.accent,
              fontFamily: 'Raleway',
              fontSize: s.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
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
                : Colors.white
                .withValues(alpha: 0.055),
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
              color: Colors.white
                  .withValues(alpha: 0.09),
            ),
            boxShadow:
            isPrimary && enabled
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
                    : Colors.white
                    .withValues(alpha: 0.72),
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