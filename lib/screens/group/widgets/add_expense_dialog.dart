import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/utils/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../core/utils/split_calculator.dart';

import '../../../features/transactions/widgets/equal_split_preview.dart';
import '../../../features/transactions/widgets/exact_split_input.dart';
import '../../../features/transactions/widgets/member_dropdown.dart';
import '../../../features/transactions/widgets/member_multi_select.dart';
import '../../../features/transactions/widgets/option_dropdown.dart';
import '../../../features/transactions/widgets/percentage_split_input.dart';

import '../../../models/group_model.dart';
import '../../../providers/transaction_provider.dart';

class AddExpenseDialog extends StatefulWidget {
  final GroupModel group;

  const AddExpenseDialog({
    super.key,
    required this.group,
  });

  @override
  State<AddExpenseDialog> createState() =>
      _AddExpenseDialogState();
}

class _AddExpenseDialogState
    extends State<AddExpenseDialog> {
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

  // ================================================================
  // SELECTED MEMBERS
  // ================================================================

  List<GroupMemberModel> get _selectedMembers {
    return widget.group.memberDetails
        .where(
          (member) =>
          selectedParticipantIds.contains(member.id),
    )
        .toList();
  }

  // ================================================================
  // AMOUNT
  // ================================================================

  double? get _amount {
    return double.tryParse(
      amountController.text.trim(),
    );
  }

  // ================================================================
  // VALIDATE PARTICIPANT SHARES
  // ================================================================

  bool _areAllParticipantSharesValid() {
    if (selectedParticipantIds.length < 2) {
      return false;
    }

    for (final participantId
    in selectedParticipantIds) {
      final share = calculatedShares[participantId];

      if (share == null || share <= 0) {
        return false;
      }
    }

    return true;
  }

  // ================================================================
  // ADD BUTTON ENABLED
  // ================================================================

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

    // If payer is the only selected participant,
    // there is no IOU to create.
    if (selectedParticipantIds.length == 1 &&
        selectedParticipantIds.first ==
            selectedPaidBy) {
      return false;
    }

    // One participant receives the complete expense.
    // No split type is required.
    if (selectedParticipantIds.length == 1) {
      return true;
    }

    // Two or more participants require a split type.
    if (selectedSplitType == null) {
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

  // ================================================================
  // EQUAL SPLIT
  // ================================================================

  void _calculateEqualShares() {
    calculatedShares = {};

    if (selectedSplitType != 'Equal') {
      return;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return;
    }

    if (selectedParticipantIds.length < 2) {
      return;
    }

    calculatedShares =
        SplitCalculator.calculateEqual(
          amount: amount,
          participantIds:
          selectedParticipantIds.toList(),
        );
  }

  // ================================================================
  // EXACT SPLIT
  // ================================================================

  void _calculateExactShares() {
    calculatedShares = {};

    if (selectedSplitType != 'Exact') {
      return;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return;
    }

    if (selectedParticipantIds.length < 2) {
      return;
    }

    calculatedShares =
        SplitCalculator.calculateExact(
          amount: amount,
          participantIds:
          selectedParticipantIds.toList(),
          enteredAmounts: exactAmounts,
        );
  }

  // ================================================================
  // PERCENTAGE SPLIT
  // ================================================================

  void _calculatePercentageShares() {
    calculatedShares = {};

    if (selectedSplitType != 'Percentage') {
      return;
    }

    final amount = _amount;

    if (amount == null || amount <= 0) {
      return;
    }

    if (selectedParticipantIds.length < 2) {
      return;
    }

    calculatedShares =
        SplitCalculator.calculatePercentage(
          amount: amount,
          participantIds:
          selectedParticipantIds.toList(),
          enteredPercentages:
          enteredPercentages,
        );
  }

  // ================================================================
  // SPLIT TYPE CHANGED
  // ================================================================

  void _handleSplitTypeChanged(
      String? value,
      ) {
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

  // ================================================================
  // PARTICIPANTS CHANGED
  // ================================================================

  void _handleParticipantsChanged(
      Set<String> values,
      ) {
    setState(() {
      selectedParticipantIds
        ..clear()
        ..addAll(values);

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

  // ================================================================
  // ADD EXPENSE
  // ================================================================

  Future<void> _handleAddExpense() async {
    if (!_isAddEnabled) {
      return;
    }

    final amount = _amount;

    if (amount == null || selectedPaidBy == null) {
      return;
    }

    final participantIds =
    selectedParticipantIds.toList();

    String splitType;
    List<Map<String, dynamic>> splitDetails;

    if (participantIds.length == 1) {
      splitType = 'exact';

      splitDetails = [
        {
          'user_id': participantIds.first,
          'value': amount,
        },
      ];
    } else if (selectedSplitType == 'Equal') {
      splitType = 'equal';

      splitDetails = participantIds.map(
            (userId) {
          return {
            'user_id': userId,
          };
        },
      ).toList();
    } else if (selectedSplitType == 'Exact') {
      splitType = 'exact';

      splitDetails = participantIds.map(
            (userId) {
          return {
            'user_id': userId,
            'value':
            calculatedShares[userId] ?? 0,
          };
        },
      ).toList();
    } else if (selectedSplitType ==
        'Percentage') {
      splitType = 'percentage';

      splitDetails = participantIds.map(
            (userId) {
          return {
            'user_id': userId,
            'value':
            enteredPercentages[userId] ?? 0,
          };
        },
      ).toList();
    } else {
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      await context
          .read<TransactionProvider>()
          .createExpense(
        groupId: widget.group.id,
        description:
        descriptionController.text.trim(),
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
        e.toString().replaceFirst(
          'Exception: ',
          '',
        ),
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

  // ================================================================
  // BUILD
  // ================================================================

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
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(
            maxHeight:
            MediaQuery.of(context).size.height *
                0.88,
          ),
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
            borderRadius: BorderRadius.circular(
              s.w(20),
            ),
            border: Border.all(
              color: AppColors.primary.withValues(
                alpha: 0.32,
              ),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(
                  alpha: 0.60,
                ),
                blurRadius: 28,
                offset: const Offset(0, 10),
              ),
              BoxShadow(
                color: AppColors.primary.withValues(
                  alpha: 0.12,
                ),
                blurRadius: 24,
                spreadRadius: 1,
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(
              s.w(20),
            ),
            child: Stack(
              children: [
                // =========================================================
                // TOP-RIGHT PURPLE GLOW
                // =========================================================

                Positioned(
                  top: -s.h(100),
                  right: -s.w(100),
                  child: Container(
                    width: s.w(220),
                    height: s.w(220),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.primary
                              .withValues(
                            alpha: 0.14,
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

                // =========================================================
                // BOTTOM-LEFT PURPLE GLOW
                // =========================================================

                Positioned(
                  bottom: -s.h(100),
                  left: -s.w(120),
                  child: Container(
                    width: s.w(240),
                    height: s.w(240),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppColors.accent
                              .withValues(
                            alpha: 0.10,
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

                // =========================================================
                // CONTENT
                // =========================================================

                Padding(
                  padding: EdgeInsets.fromLTRB(
                    s.w(20),
                    s.h(20),
                    s.w(20),
                    s.h(16),
                  ),
                  child: SingleChildScrollView(
                    controller:
                    _dialogScrollController,
                    keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior
                        .manual,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        // =================================================
                        // TITLE
                        // =================================================

                        Row(
                          children: [
                            Container(
                              width: s.w(38),
                              height: s.w(38),
                              decoration:
                              BoxDecoration(
                                shape: BoxShape.circle,
                                gradient:
                                const LinearGradient(
                                  begin:
                                  Alignment.topLeft,
                                  end: Alignment
                                      .bottomRight,
                                  colors: [
                                    AppColors.accent,
                                    AppColors.primary,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors
                                        .primary
                                        .withValues(
                                      alpha: 0.20,
                                    ),
                                    blurRadius: 12,
                                  ),
                                ],
                              ),
                              child: Icon(
                                Icons
                                    .receipt_long_rounded,
                                color: Colors.white,
                                size: s.sp(19),
                              ),
                            ),
                            SizedBox(
                              width: s.w(12),
                            ),
                            Text(
                              'Add Expense',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontSize: s.sp(22),
                                fontWeight:
                                FontWeight.w600,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: s.h(22),
                        ),

                        // =================================================
                        // DESCRIPTION
                        // =================================================

                        _FieldLabel(
                          text: 'Description',
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(7),
                        ),

                        _DialogTextField(
                          controller:
                          descriptionController,
                          hintText:
                          'What was this expense for?',
                          keyboardType:
                          TextInputType.text,
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(17),
                        ),

                        // =================================================
                        // AMOUNT
                        // =================================================

                        _FieldLabel(
                          text: 'Amount',
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(7),
                        ),

                        _DialogTextField(
                          controller:
                          amountController,
                          hintText: 'Enter amount',
                          keyboardType:
                          const TextInputType
                              .numberWithOptions(
                            decimal: true,
                          ),
                          onChanged: (_) {
                            setState(() {
                              if (selectedSplitType ==
                                  'Equal') {
                                _calculateEqualShares();
                              } else if (
                              selectedSplitType ==
                                  'Exact') {
                                _calculateExactShares();
                              } else if (
                              selectedSplitType ==
                                  'Percentage') {
                                _calculatePercentageShares();
                              }
                            });
                          },
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(17),
                        ),

                        // =================================================
                        // PAID BY
                        // =================================================

                        _FieldLabel(
                          text: 'Paid By',
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(7),
                        ),

                        MemberDropdown(
                          value: selectedPaidBy,
                          hintText: 'Select who paid',
                          members:
                          widget.group.memberDetails,
                          onChanged: (value) {
                            setState(() {
                              selectedPaidBy = value;
                            });
                          },
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(17),
                        ),

                        // =================================================
                        // SPLIT BETWEEN
                        // =================================================

                        _FieldLabel(
                          text: 'Split Between',
                          s: s,
                        ),

                        SizedBox(
                          height: s.h(7),
                        ),

                        MemberMultiSelect(
                          selectedValues:
                          selectedParticipantIds,
                          members:
                          widget.group.memberDetails,
                          hintText: 'Select members',
                          onChanged:
                          _handleParticipantsChanged,
                          s: s,
                        ),

                        // =================================================
                        // SPLIT OPTIONS
                        // =================================================

                        if (selectedParticipantIds
                            .length >=
                            2) ...[
                          SizedBox(
                            height: s.h(17),
                          ),

                          _FieldLabel(
                            text: 'Split Type',
                            s: s,
                          ),

                          SizedBox(
                            height: s.h(7),
                          ),

                          OptionDropdown(
                            value: selectedSplitType,
                            hintText:
                            'Select split type',
                            items: const [
                              'Equal',
                              'Exact',
                              'Percentage',
                            ],
                            onChanged:
                            _handleSplitTypeChanged,
                            s: s,
                          ),

                          if (selectedSplitType ==
                              'Equal' &&
                              calculatedShares
                                  .isNotEmpty) ...[
                            SizedBox(
                              height: s.h(14),
                            ),
                            EqualSplitPreview(
                              members:
                              _selectedMembers,
                              shares:
                              calculatedShares,
                              s: s,
                            ),
                          ],

                          if (selectedSplitType ==
                              'Exact') ...[
                            SizedBox(
                              height: s.h(14),
                            ),
                            ExactSplitInput(
                              members:
                              _selectedMembers,
                              totalAmount:
                              _amount ?? 0,
                              initialAmounts:
                              exactAmounts,
                              onChanged: (values) {
                                setState(() {
                                  exactAmounts =
                                      values;
                                  _calculateExactShares();
                                });
                              },
                              s: s,
                            ),
                          ],

                          if (selectedSplitType ==
                              'Percentage') ...[
                            SizedBox(
                              height: s.h(14),
                            ),

                            PercentageSplitInput(
                              members:
                              _selectedMembers,
                              initialPercentages:
                              enteredPercentages,
                              onChanged: (values) {
                                setState(() {
                                  enteredPercentages =
                                      values;
                                  _calculatePercentageShares();
                                });
                              },
                              s: s,
                            ),

                            if (calculatedShares
                                .isNotEmpty) ...[
                              SizedBox(
                                height: s.h(10),
                              ),

                              _PercentageSharePreview(
                                members:
                                _selectedMembers,
                                shares:
                                calculatedShares,
                                s: s,
                              ),
                            ],
                          ],
                        ],

                        SizedBox(
                          height: s.h(24),
                        ),

                        // =================================================
                        // ACTION BUTTONS
                        // =================================================

                        Row(
                          mainAxisAlignment:
                          MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: _isSubmitting
                                  ? null
                                  : () {
                                Navigator.pop(
                                  context,
                                );
                              },
                              child: Padding(
                                padding:
                                EdgeInsets.symmetric(
                                  horizontal: s.w(12),
                                  vertical: s.h(10),
                                ),
                                child: Text(
                                  'CANCEL',
                                  style: TextStyle(
                                    color: _isSubmitting
                                        ? Colors.white38
                                        : Colors.white70,
                                    fontFamily:
                                    'Raleway',
                                    fontSize: s.sp(13),
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),

                            SizedBox(
                              width: s.w(6),
                            ),

                            GestureDetector(
                              onTap: _isAddEnabled
                                  ? _handleAddExpense
                                  : null,
                              child: Container(
                                padding:
                                EdgeInsets.symmetric(
                                  horizontal: s.w(20),
                                  vertical: s.h(11),
                                ),
                                decoration:
                                BoxDecoration(
                                  gradient:
                                  LinearGradient(
                                    begin:
                                    Alignment.topLeft,
                                    end: Alignment
                                        .bottomRight,
                                    colors: _isAddEnabled
                                        ? const [
                                      AppColors
                                          .accent,
                                      AppColors
                                          .primary,
                                    ]
                                        : [
                                      AppColors
                                          .accent
                                          .withValues(
                                        alpha: 0.30,
                                      ),
                                      AppColors
                                          .primary
                                          .withValues(
                                        alpha: 0.30,
                                      ),
                                    ],
                                  ),
                                  borderRadius:
                                  BorderRadius.circular(
                                    s.w(10),
                                  ),
                                  border: Border.all(
                                    color: AppColors
                                        .accent
                                        .withValues(
                                      alpha:
                                      _isAddEnabled
                                          ? 0.40
                                          : 0.12,
                                    ),
                                  ),
                                  boxShadow:
                                  _isAddEnabled
                                      ? [
                                    BoxShadow(
                                      color: AppColors
                                          .primary
                                          .withValues(
                                        alpha:
                                        0.30,
                                      ),
                                      blurRadius:
                                      12,
                                      spreadRadius:
                                      1,
                                    ),
                                  ]
                                      : [],
                                ),
                                child: Text(
                                  _isSubmitting
                                      ? 'ADDING...'
                                      : 'ADD',
                                  style: TextStyle(
                                    color: _isAddEnabled
                                        ? Colors.white
                                        : Colors.white54,
                                    fontFamily:
                                    'Raleway',
                                    fontSize: s.sp(13),
                                    fontWeight:
                                    FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        // =================================================
                        // KEYBOARD SPACE
                        // =================================================

                        if (keyboardHeight > 0)
                          SizedBox(
                            height:
                            keyboardHeight +
                                s.h(80),
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
    );
  }
}

// ===========================================================================
// FIELD LABEL
// ===========================================================================

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
        color: Colors.white,
        fontFamily: 'Raleway',
        fontSize: s.sp(14),
        fontWeight: FontWeight.w500,
      ),
    );
  }
}

// ===========================================================================
// DIALOG TEXT FIELD
// ===========================================================================

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
    this.onChanged,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: s.h(46),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        onChanged: onChanged,
        style: TextStyle(
          color: Colors.white,
          fontFamily: 'Raleway',
          fontSize: s.sp(14),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            color: Colors.white.withValues(
              alpha: 0.32,
            ),
            fontFamily: 'Raleway',
            fontSize: s.sp(13),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: s.w(13),
            vertical: s.h(9),
          ),
          filled: true,
          fillColor: Colors.white.withValues(
            alpha: 0.045,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              s.w(10),
            ),
            borderSide: BorderSide(
              color: AppColors.primary.withValues(
                alpha: 0.18,
              ),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              s.w(10),
            ),
            borderSide: BorderSide(
              color: Colors.white.withValues(
                alpha: 0.10,
              ),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(
              s.w(10),
            ),
            borderSide: const BorderSide(
              color: AppColors.primary,
              width: 1.3,
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// PERCENTAGE SHARE PREVIEW
// ===========================================================================

class _PercentageSharePreview
    extends StatelessWidget {
  final List<GroupMemberModel> members;
  final Map<String, double> shares;
  final AppScaler s;

  const _PercentageSharePreview({
    required this.members,
    required this.shares,
    required this.s,
  });

  @override
  Widget build(BuildContext context) {
    if (shares.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(
        s.w(12),
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.045,
        ),
        borderRadius: BorderRadius.circular(
          s.w(12),
        ),
        border: Border.all(
          color: AppColors.primary.withValues(
            alpha: 0.20,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment:
        CrossAxisAlignment.start,
        children: [
          Text(
            'Calculated Shares',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontSize: s.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(
            height: s.h(10),
          ),

          ...members.map(
                (member) {
              final share =
                  shares[member.id] ?? 0;

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
                      '₹${share.toStringAsFixed(2)}',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'Raleway',
                        fontSize: s.sp(13),
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