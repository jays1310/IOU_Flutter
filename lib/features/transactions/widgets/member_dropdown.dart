import 'package:flutter/material.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';

class MemberDropdown extends StatefulWidget {
  final String? value;
  final String hintText;
  final List<GroupMemberModel> members;
  final ValueChanged<String?> onChanged;
  final AppScaler s;

  const MemberDropdown({
    super.key,
    required this.value,
    required this.hintText,
    required this.members,
    required this.onChanged,
    required this.s,
  });

  @override
  State<MemberDropdown> createState() => _MemberDropdownState();
}

class _MemberDropdownState extends State<MemberDropdown> {
  final LayerLink _layerLink = LayerLink();

  final ScrollController _scrollController =
  ScrollController();

  OverlayEntry? _overlayEntry;

  bool get _isOpen => _overlayEntry != null;

  String? get _selectedUsername {
    if (widget.value == null) {
      return null;
    }

    for (final member in widget.members) {
      if (member.id == widget.value) {
        return member.username;
      }
    }

    return null;
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

            /// Anchored member menu.
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
                            member.id == widget.value;

                        return InkWell(
                          onTap: () {
                            widget.onChanged(member.id);
                            _closeMenu();
                          },
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: widget.s.w(12),
                            ),
                            alignment: Alignment.centerLeft,
                            color: isSelected
                                ? Colors.white.withValues(
                              alpha: 0.12,
                            )
                                : Colors.transparent,
                            child: Text(
                              member.username,
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'Raleway',
                                fontSize: widget.s.sp(14),
                              ),
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
                  _selectedUsername ?? widget.hintText,
                  style: TextStyle(
                    color: _selectedUsername == null
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