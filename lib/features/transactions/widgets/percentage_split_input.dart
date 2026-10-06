import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';

class PercentageSplitInput extends StatefulWidget {
  final List<GroupMemberModel> members;
  final Map<String, double> initialPercentages;
  final ValueChanged<Map<String, double>> onChanged;
  final AppScaler s;

  const PercentageSplitInput({
    super.key,
    required this.members,
    required this.initialPercentages,
    required this.onChanged,
    required this.s,
  });

  @override
  State<PercentageSplitInput> createState() =>
      _PercentageSplitInputState();
}

class _PercentageSplitInputState
    extends State<PercentageSplitInput> {
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, FocusNode> _focusNodes = {};
  final Map<String, GlobalKey> _fieldKeys = {};

  @override
  void initState() {
    super.initState();
    _createControllers();
  }

  @override
  void didUpdateWidget(
      covariant PercentageSplitInput oldWidget,
      ) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.members.map((e) => e.id).join(',') !=
        widget.members.map((e) => e.id).join(',')) {
      _disposeControllers();
      _createControllers();
    }
  }

  void _createControllers() {
    _controllers.clear();
    _focusNodes.clear();
    _fieldKeys.clear();

    if (widget.members.length <= 1) {
      return;
    }

    for (int i = 0; i < widget.members.length - 1; i++) {
      final member = widget.members[i];

      final existingPercentage =
      widget.initialPercentages[member.id];

      final controller = TextEditingController(
        text: existingPercentage == null
            ? ''
            : existingPercentage.toStringAsFixed(2),
      );

      final focusNode = FocusNode();
      final fieldKey = GlobalKey();

      controller.addListener(_handleInputChanged);

      focusNode.addListener(() {
        if (focusNode.hasFocus) {
          _scrollFieldIntoView(fieldKey);
        }
      });

      _controllers[member.id] = controller;
      _focusNodes[member.id] = focusNode;
      _fieldKeys[member.id] = fieldKey;
    }
  }

  void _scrollFieldIntoView(GlobalKey fieldKey) {
    Future.delayed(
      const Duration(milliseconds: 300),
          () {
        if (!mounted) {
          return;
        }

        final fieldContext = fieldKey.currentContext;

        if (fieldContext == null || !fieldContext.mounted) {
          return;
        }

        Scrollable.ensureVisible(
          fieldContext,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          alignment: 0.25,
        );
      },
    );
  }

  void _handleInputChanged() {
    _updateValues();
  }

  void _updateValues() {
    if (widget.members.length < 2) {
      widget.onChanged({});
      return;
    }

    final Map<String, double> percentages = {};

    double enteredTotal = 0;

    for (int i = 0; i < widget.members.length - 1; i++) {
      final member = widget.members[i];
      final controller = _controllers[member.id];

      if (controller == null) {
        continue;
      }

      final value = double.tryParse(
        controller.text.trim(),
      );

      if (value == null || value < 0) {
        continue;
      }

      percentages[member.id] = value;
      enteredTotal += value;
    }

    final remaining = 100 - enteredTotal;

    final lastMember = widget.members.last;

    percentages[lastMember.id] =
    remaining >= 0 ? remaining : 0;

    widget.onChanged(percentages);

    if (mounted) {
      setState(() {});
    }
  }

  double _getEnteredTotal() {
    double total = 0;

    for (final controller in _controllers.values) {
      final value = double.tryParse(
        controller.text.trim(),
      );

      if (value != null && value >= 0) {
        total += value;
      }
    }

    return total;
  }

  double _getRawRemainingPercentage() {
    return 100 - _getEnteredTotal();
  }

  bool _hasExceededTotal() {
    return _getRawRemainingPercentage() < 0;
  }

  double _getExceededPercentage() {
    final rawRemaining = _getRawRemainingPercentage();

    if (rawRemaining >= 0) {
      return 0;
    }

    return rawRemaining.abs();
  }

  bool _hasZeroRemainingShare() {
    if (_hasExceededTotal()) {
      return false;
    }

    return _getRawRemainingPercentage() == 0;
  }

  bool _hasInvalidEnteredPercentage() {
    for (final controller in _controllers.values) {
      final text = controller.text.trim();

      if (text.isEmpty) {
        return true;
      }

      final value = double.tryParse(text);

      if (value == null || value <= 0) {
        return true;
      }
    }

    return false;
  }

  bool _isInvalidMemberInput(String memberId) {
    final controller = _controllers[memberId];

    if (controller == null) {
      return true;
    }

    final text = controller.text.trim();

    if (text.isEmpty) {
      return true;
    }

    final value = double.tryParse(text);

    return value == null || value <= 0;
  }

  String _formatPercentage(double percentage) {
    return percentage.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  void _disposeControllers() {
    for (final controller in _controllers.values) {
      controller.removeListener(_handleInputChanged);
      controller.dispose();
    }

    for (final focusNode in _focusNodes.values) {
      focusNode.dispose();
    }

    _controllers.clear();
    _focusNodes.clear();
    _fieldKeys.clear();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.members.length < 2) {
      return const SizedBox.shrink();
    }

    final rawRemaining = _getRawRemainingPercentage();
    final hasExceeded = _hasExceededTotal();
    final hasZeroRemainingShare =
    _hasZeroRemainingShare();
    final hasInvalidEnteredPercentage =
    _hasInvalidEnteredPercentage();

    final displayedRemaining = hasExceeded
        ? _getExceededPercentage()
        : 0.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(widget.s.w(12)),
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
            'Percentage Split',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontSize: widget.s.sp(13),
              fontWeight: FontWeight.w600,
            ),
          ),

          SizedBox(height: widget.s.h(10)),

          ...List.generate(
            widget.members.length,
                (index) {
              final member = widget.members[index];
              final isLast =
                  index == widget.members.length - 1;

              final isInvalidInput =
                  !isLast &&
                      _isInvalidMemberInput(member.id);

              return Padding(
                padding: EdgeInsets.only(
                  bottom: isLast ? 0 : widget.s.h(8),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        member.username,
                        style: TextStyle(
                          color: isInvalidInput
                              ? Colors.redAccent
                              : Colors.white70,
                          fontFamily: 'Raleway',
                          fontSize: widget.s.sp(13),
                        ),
                      ),
                    ),

                    SizedBox(width: widget.s.w(10)),

                    SizedBox(
                      width: widget.s.w(110),
                      height: widget.s.h(40),
                      child: isLast
                          ? Container(
                        alignment:
                        Alignment.centerRight,
                        padding:
                        EdgeInsets.symmetric(
                          horizontal:
                          widget.s.w(10),
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(
                            alpha: 0.05,
                          ),
                          borderRadius:
                          BorderRadius.circular(7),
                          border: Border.all(
                            color: hasExceeded ||
                                hasZeroRemainingShare
                                ? Colors.redAccent
                                : AppColors.primary
                                .withValues(
                              alpha: 0.25,
                            ),
                          ),
                        ),
                        child: Text(
                          '${_formatPercentage(
                            rawRemaining < 0
                                ? 0
                                : rawRemaining,
                          )}%',
                          style: TextStyle(
                            color: hasExceeded ||
                                hasZeroRemainingShare
                                ? Colors.redAccent
                                : Colors.white,
                            fontFamily: 'Raleway',
                            fontSize:
                            widget.s.sp(13),
                            fontWeight:
                            FontWeight.w600,
                          ),
                        ),
                      )
                          : TextField(
                        key: _fieldKeys[member.id],
                        controller:
                        _controllers[member.id],
                        focusNode:
                        _focusNodes[member.id],
                        keyboardType:
                        const TextInputType
                            .numberWithOptions(
                          decimal: true,
                        ),
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: isInvalidInput
                              ? Colors.redAccent
                              : Colors.white,
                          fontFamily: 'Raleway',
                          fontSize:
                          widget.s.sp(13),
                        ),
                        decoration:
                        InputDecoration(
                          suffixText: '%',
                          suffixStyle: TextStyle(
                            color: isInvalidInput
                                ? Colors.redAccent
                                : Colors.white54,
                            fontFamily: 'Raleway',
                            fontSize:
                            widget.s.sp(13),
                          ),
                          hintText: '0.00',
                          hintStyle: TextStyle(
                            color: isInvalidInput
                                ? Colors.redAccent
                                .withValues(
                              alpha: 0.55,
                            )
                                : Colors.white30,
                            fontFamily: 'Raleway',
                            fontSize:
                            widget.s.sp(13),
                          ),
                          contentPadding:
                          EdgeInsets.symmetric(
                            horizontal:
                            widget.s.w(10),
                            vertical:
                            widget.s.h(7),
                          ),
                          filled: true,
                          fillColor:
                          const Color(0xFF211827),
                          border:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                7),
                            borderSide: BorderSide(
                              color: isInvalidInput
                                  ? Colors.redAccent
                                  : Colors.white
                                  .withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                          enabledBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                7),
                            borderSide: BorderSide(
                              color: isInvalidInput
                                  ? Colors.redAccent
                                  : Colors.white
                                  .withValues(
                                alpha: 0.12,
                              ),
                            ),
                          ),
                          focusedBorder:
                          OutlineInputBorder(
                            borderRadius:
                            BorderRadius.circular(
                                7),
                            borderSide: BorderSide(
                              color: isInvalidInput
                                  ? Colors.redAccent
                                  : AppColors.primary,
                              width: 1.3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),

          SizedBox(height: widget.s.h(10)),

          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                hasExceeded
                    ? 'Exceeded'
                    : 'Remaining',
                style: TextStyle(
                  color: hasExceeded ||
                      hasZeroRemainingShare ||
                      hasInvalidEnteredPercentage
                      ? Colors.redAccent
                      : Colors.white54,
                  fontFamily: 'Raleway',
                  fontSize: widget.s.sp(12),
                ),
              ),
              Text(
                '${_formatPercentage(displayedRemaining)}%',
                style: TextStyle(
                  color: hasExceeded ||
                      hasZeroRemainingShare ||
                      hasInvalidEnteredPercentage
                      ? Colors.redAccent
                      : Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: widget.s.sp(12),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),

          if (hasExceeded) ...[
            SizedBox(height: widget.s.h(6)),
            Text(
              'Entered percentages exceed 100%.',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Raleway',
                fontSize: widget.s.sp(11),
              ),
            ),
          ] else if (hasInvalidEnteredPercentage ||
              hasZeroRemainingShare) ...[
            SizedBox(height: widget.s.h(6)),
            Text(
              'This member has no remaining share.',
              style: TextStyle(
                color: Colors.redAccent,
                fontFamily: 'Raleway',
                fontSize: widget.s.sp(11),
              ),
            ),
          ],
        ],
      ),
    );
  }
}