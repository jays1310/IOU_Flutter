import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import 'fab_menu_item.dart';
import 'dart:ui';

class HomeFAB extends StatefulWidget {
  const HomeFAB({
    super.key,
    required this.onCreateGroup,
    required this.onJoinGroup,
    required this.onAddContact,
  });

  final VoidCallback onCreateGroup;
  final VoidCallback onJoinGroup;
  final VoidCallback onAddContact;

  @override
  State<HomeFAB> createState() => _HomeFABState();
}

class _HomeFABState extends State<HomeFAB> {
  bool _isOpen = false;

  void _toggle() {
    setState(() {
      _isOpen = !_isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        AnimatedSlide(
          offset: _isOpen
              ? Offset.zero
              : const Offset(0, 0.15),
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          child: AnimatedOpacity(
            opacity: _isOpen ? 1 : 0,
            duration: const Duration(milliseconds: 180),
            child: IgnorePointer(
              ignoring: !_isOpen,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(18),
                child: BackdropFilter(
                  filter: ImageFilter.blur(
                    sigmaX: 12,
                    sigmaY: 12,
                  ),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: s.w(12),
                      vertical: s.h(8),
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.25),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        FabMenuItem(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Add Contact',
                          onTap: widget.onAddContact,
                        ),

                        FabMenuItem(
                          icon: Icons.group_add_rounded,
                          label: 'Join Group',
                          onTap: widget.onJoinGroup,
                        ),

                        FabMenuItem(
                          icon: Icons.groups_rounded,
                          label: 'Create Group',
                          onTap: widget.onCreateGroup,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),

        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: s.w(54),
            height: s.w(54),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.accent,
                width: 3,
              ),
            ),
            child: AnimatedRotation(
              turns: _isOpen ? 0.125 : 0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeInOut,
              child: Icon(
                _isOpen ? Icons.close : Icons.add,
                color: AppColors.accent,
                size: s.sp(32),
              ),
            ),
          ),
        ),
      ],
    );
  }
}