import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';

class MemberMultiSelect extends StatefulWidget {
  final Set<String> selectedValues;
  final List<GroupMemberModel> members;
  final String hintText;
  final ValueChanged<Set<String>> onChanged;
  final AppScaler s;

  const MemberMultiSelect({
    super.key,
    required this.selectedValues,
    required this.members,
    required this.hintText,
    required this.onChanged,
    required this.s,
  });

  @override
  State<MemberMultiSelect> createState() =>
      _MemberMultiSelectState();
}

class _MemberMultiSelectState
    extends State<MemberMultiSelect> {
  final LayerLink _layerLink = LayerLink();

  final ScrollController _scrollController =
  ScrollController();

  OverlayEntry? _overlayEntry;

  bool get _isOpen => _overlayEntry != null;

  String get _selectedText {
    final selectedMembers = widget.members
        .where(
          (member) =>
          widget.selectedValues.contains(member.id),
    )
        .toList();

    if (selectedMembers.isEmpty) {
      return widget.hintText;
    }

    if (selectedMembers.length == 1) {
      return selectedMembers.first.username;
    }

    return '${selectedMembers.length} members selected';
  }

  void _toggleMenu() {
    if (_isOpen) {
      _closeMenu();
    } else {
      _openMenu();
    }
  }

  void _openMenu() {
    final renderBox =
    context.findRenderObject() as RenderBox;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            /// Transparent area used to close the menu.
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _closeMenu,
              ),
            ),

            /// Anchored multi-member menu.
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              targetAnchor: Alignment.bottomLeft,
              followerAnchor: Alignment.topLeft,
              offset: const Offset(0, 4),
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: size.width,
                  constraints: BoxConstraints(
                    maxHeight: widget.s.h(44 * 4),
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF29202F),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: Colors.white.withValues(
                        alpha: 0.10,
                      ),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: 0.45,
                        ),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility:
                    widget.members.length > 4,
                    child: ListView.builder(
                      controller: _scrollController,
                      padding: EdgeInsets.zero,
                      itemCount: widget.members.length,
                      itemExtent: widget.s.h(44),
                      itemBuilder: (context, index) {
                        final member =
                        widget.members[index];

                        final isSelected =
                        widget.selectedValues.contains(
                          member.id,
                        );

                        return InkWell(
                          onTap: () {
                            final updated =
                            Set<String>.from(
                              widget.selectedValues,
                            );

                            if (isSelected) {
                              updated.remove(member.id);
                            } else {
                              updated.add(member.id);
                            }

                            widget.onChanged(updated);

                            // Keep the menu open so multiple
                            // members can be selected.
                            _refreshMenu();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.s.w(12),
                            ),
                            color: isSelected
                                ? Colors.white.withValues(
                              alpha: 0.12,
                            )
                                : Colors.transparent,
                            child: Row(
                              children: [
                                SizedBox(
                                  width: widget.s.w(28),
                                  child: Checkbox(
                                    value: isSelected,
                                    onChanged: (_) {
                                      final updated =
                                      Set<String>.from(
                                        widget.selectedValues,
                                      );

                                      if (isSelected) {
                                        updated.remove(
                                          member.id,
                                        );
                                      } else {
                                        updated.add(
                                          member.id,
                                        );
                                      }

                                      widget.onChanged(
                                        updated,
                                      );

                                      _refreshMenu();
                                    },
                                    activeColor:
                                    AppColors.primary,
                                    checkColor: Colors.white,
                                    side: const BorderSide(
                                      color: Colors.white54,
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: widget.s.w(8),
                                ),
                                Expanded(
                                  child: Text(
                                    member.username,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'Raleway',
                                      fontSize:
                                      widget.s.sp(14),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);

    setState(() {});
  }

  void _refreshMenu() {
    _overlayEntry?.markNeedsBuild();
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CompositedTransformTarget(
      link: _layerLink,
      child: GestureDetector(
        onTap: _toggleMenu,
        child: Container(
          height: widget.s.h(44),
          decoration: BoxDecoration(
            color: const Color(0xFF18111E),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: Colors.white.withValues(
                alpha: 0.12,
              ),
            ),
          ),
          padding: EdgeInsets.symmetric(
            horizontal: widget.s.w(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  _selectedText,
                  style: TextStyle(
                    color: widget.selectedValues.isEmpty
                        ? Colors.white38
                        : Colors.white,
                    fontFamily: 'Raleway',
                    fontSize: widget.s.sp(14),
                  ),
                ),
              ),
              Icon(
                _isOpen
                    ? Icons.keyboard_arrow_up_rounded
                    : Icons.keyboard_arrow_down_rounded,
                color: Colors.white70,
              ),
            ],
          ),
        ),
      ),
    );
  }
}