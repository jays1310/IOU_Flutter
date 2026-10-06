import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import 'fab_menu_item.dart';

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
        // ===========================================================
        // EXPANDED MENU
        // ===========================================================

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
                      color: Colors.white.withValues(
                        alpha: 0.05,
                      ),
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(
                        color: AppColors.accent.withValues(
                          alpha: 0.25,
                        ),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment:
                      CrossAxisAlignment.start,
                      children: [
                        FabMenuItem(
                          icon: Icons.person_add_alt_1_rounded,
                          label: 'Add Individual',
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

        // Space between menu and FAB
        SizedBox(
          height: s.h(10),
        ),

        // ===========================================================
        // GLASS FAB
        // ===========================================================

        GestureDetector(
          onTap: _toggle,
          child: Container(
            width: s.w(58),
            height: s.w(58),
            decoration: BoxDecoration(
              shape: BoxShape.circle,

              // Soft glow behind the glass
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withValues(
                    alpha: 0.35,
                  ),
                  blurRadius: 18,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: ClipOval(
              child: BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: 10,
                  sigmaY: 10,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,

                    // Glassy gradient
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        AppColors.primary.withValues(
                          alpha: 0.32,
                        ),
                        AppColors.accent.withValues(
                          alpha: 0.18,
                        ),
                        Colors.white.withValues(
                          alpha: 0.07,
                        ),
                      ],
                    ),

                    // Glass border
                    border: Border.all(
                      color: AppColors.accent.withValues(
                        alpha: 0.85,
                      ),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: AnimatedRotation(
                      turns: _isOpen ? 0.125 : 0,
                      duration: const Duration(
                        milliseconds: 250,
                      ),
                      curve: Curves.easeInOut,
                      child: Icon(
                        _isOpen
                            ? Icons.close
                            : Icons.add,
                        color: Colors.white,
                        size: s.sp(32),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}