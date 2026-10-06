import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../group_detail_screen.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/app_scaler.dart';
import '../../../models/group_model.dart';
import '../../../providers/group_provider.dart';

class GroupToolbar extends StatelessWidget {
  final GroupModel group;

  const GroupToolbar({
    super.key,
    required this.group,
  });

  // ================================================================
  // LEAVE GROUP
  // ================================================================

  Future<void> _leaveGroup(BuildContext context) async {
    final shouldLeave = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          backgroundColor: AppColors.card,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Leave Group',
            style: TextStyle(
              color: Colors.white,
              fontFamily: 'Raleway',
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'Are you sure you want to leave "${group.groupName}"?',
            style: TextStyle(
              color: Colors.white.withValues(
                alpha: 0.70,
              ),
              fontFamily: 'Raleway',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  false,
                );
              },
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: AppColors.accent,
                  fontFamily: 'Raleway',
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(
                  dialogContext,
                  true,
                );
              },
              child: const Text(
                'Leave',
                style: TextStyle(
                  color: AppColors.error,
                  fontFamily: 'Raleway',
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );

    if (shouldLeave != true || !context.mounted) {
      return;
    }

    try {
      await context.read<GroupProvider>().leaveGroup(
        groupId: group.id,
      );

      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'You have left the group',
          ),
        ),
      );

      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            e.toString().replaceFirst(
              'Exception: ',
              '',
            ),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    final initials = group.groupName
        .trim()
        .split(' ')
        .map((e) => e[0])
        .take(2)
        .join()
        .toUpperCase();

    return Container(
      width: double.infinity,

      // ================================================================
      // THEMED TOOLBAR BACKGROUND
      // ================================================================

      decoration: BoxDecoration(
        color: Colors.white.withValues(
          alpha: 0.025,
        ),
        border: Border(
          bottom: BorderSide(
            color: AppColors.primary.withValues(
              alpha: 0.12,
            ),
            width: 1,
          ),
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(
              alpha: 0.05,
            ),
            blurRadius: 14,
            spreadRadius: 0,
            offset: const Offset(
              0,
              4,
            ),
          ),
        ],
      ),

      padding: EdgeInsets.symmetric(
        horizontal: s.w(12),
        vertical: s.h(10),
      ),

      child: Stack(
        alignment: Alignment.center,
        children: [
          // ============================================================
          // LEFT + RIGHT CONTROLS
          // ============================================================

          Row(
            children: [
              // ==========================================================
              // BACK ARROW
              // ==========================================================

              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: Opacity(
                  opacity: 0.85,
                  child: SizedBox(
                    width: s.w(50),
                    height: s.h(48),
                    child: Image.asset(
                      AppAssets.backArrow,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),

              SizedBox(
                width: s.w(14),
              ),

              // ==========================================================
              // GROUP AVATAR
              // ==========================================================

              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => GroupDetailScreen(
                        group: group,
                      ),
                    ),
                  );
                },
                child: Container(
                  width: s.w(46),
                  height: s.w(46),
                  padding: EdgeInsets.all(
                    s.w(2),
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
                        color: AppColors.primary.withValues(
                          alpha: 0.20,
                        ),
                        blurRadius: 12,
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
                        fontSize: s.sp(15),
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),

              const Spacer(),

              // ==========================================================
              // THREE DOT MENU
              // ==========================================================

              PopupMenuButton<String>(
                // Keep the menu opening downward.
                position: PopupMenuPosition.under,

                color: AppColors.background,

                elevation: 12,

                shadowColor: AppColors.primary.withValues(
                  alpha: 0.30,
                ),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    s.w(14),
                  ),
                  side: BorderSide(
                    color: AppColors.primary.withValues(
                      alpha: 0.30,
                    ),
                    width: 1,
                  ),
                ),

                padding: EdgeInsets.zero,

                icon: Icon(
                  Icons.more_vert,
                  color: Colors.white.withValues(
                    alpha: 0.85,
                  ),
                  size: s.w(30),
                ),

                splashRadius: s.w(22),

                onSelected: (value) {
                  if (value == 'leave') {
                    _leaveGroup(context);
                  }
                },

                itemBuilder: (context) => [
                  PopupMenuItem<String>(
                    value: 'leave',
                    height: s.h(48),
                    child: Row(
                      children: [
                        // ----------------------------------------------
                        // LOGOUT ICON
                        // ----------------------------------------------

                        Container(
                          width: s.w(32),
                          height: s.w(32),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.error.withValues(
                              alpha: 0.10,
                            ),
                            border: Border.all(
                              color: AppColors.error.withValues(
                                alpha: 0.25,
                              ),
                            ),
                          ),
                          child: Icon(
                            Icons.logout_rounded,
                            color: AppColors.error,
                            size: s.sp(17),
                          ),
                        ),

                        SizedBox(
                          width: s.w(10),
                        ),

                        Text(
                          'Leave Group',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'Raleway',
                            fontSize: s.sp(13),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // ==============================================================
          // CENTER GROUP NAME
          // ==============================================================

          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: s.w(100),
            ),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => GroupDetailScreen(
                      group: group,
                    ),
                  ),
                );
              },
              child: Text(
                group.groupName,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  color: Colors.white,
                  fontFamily: 'Raleway',
                  fontSize: s.sp(24),
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}