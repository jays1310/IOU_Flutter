import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iou_flutter/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../providers/group_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'select_members_screen.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({
    super.key,
  });

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final TextEditingController groupNameController =
  TextEditingController();

  @override
  void dispose() {
    groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final groupProvider = context.watch<GroupProvider>();

    final keyboardHeight =
        MediaQuery.viewInsetsOf(context).bottom;

    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      padding: EdgeInsets.only(
        bottom: keyboardHeight,
      ),
      child: SafeArea(
        top: false,
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(24),
            ),
          ),
          child: SingleChildScrollView(
            keyboardDismissBehavior:
            ScrollViewKeyboardDismissBehavior.onDrag,
            padding: const EdgeInsets.fromLTRB(
              24,
              16,
              24,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // =====================================================
                // DRAG HANDLE
                // =====================================================

                Center(
                  child: Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      borderRadius:
                      BorderRadius.circular(10),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // =====================================================
                // TITLE
                // =====================================================

                Text(
                  'Create Group',
                  style: AppTextStyles.welcomeText(28),
                ),

                const SizedBox(height: 8),

                Text(
                  'Enter a name for your group',
                  style: AppTextStyles.buttonText(15).copyWith(
                    color: Colors.white70,
                  ),
                ),

                const SizedBox(height: 24),

                // =====================================================
                // GROUP NAME
                // =====================================================

                AppTextField(
                  controller: groupNameController,
                  hintText: 'Group Name',
                ),

                const SizedBox(height: 24),

                // =====================================================
                // CONTINUE
                // =====================================================

                AppButton(
                  width: double.infinity,
                  height: 50,
                  text: 'Continue',
                  isLoading: groupProvider.isLoading,
                  onPressed: () {
                    final groupName =
                    groupNameController.text.trim();

                    if (groupName.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'Please enter a group name',
                          ),
                        ),
                      );
                      return;
                    }

                    if (!mounted) return;

                    Navigator.pop(context);

                    context.push(
                      '/select-members',
                      extra: SelectMembersScreen(
                        groupName: groupName,
                      ),
                    );
                  },
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}