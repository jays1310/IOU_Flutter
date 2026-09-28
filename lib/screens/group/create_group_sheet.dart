import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../core/utils/app_scaler.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'package:iou_flutter/core/theme/app_text_styles.dart';
import 'package:provider/provider.dart';
import '../../providers/group_provider.dart';

class CreateGroupSheet extends StatefulWidget {
  const CreateGroupSheet({super.key});

  @override
  State<CreateGroupSheet> createState() => _CreateGroupSheetState();
}

class _CreateGroupSheetState extends State<CreateGroupSheet> {
  final TextEditingController _groupNameController =
  TextEditingController();

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = AppScaler(context);

    return Padding(
      padding: EdgeInsets.only(
        left: s.w(20),
        right: s.w(20),
        top: s.h(20),
        bottom: MediaQuery.of(context).viewInsets.bottom + s.h(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: s.w(50),
              height: s.h(5),
              decoration: BoxDecoration(
                color: AppColors.accent,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),

          SizedBox(height: s.h(24)),

          Text(
            'Create Group',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          SizedBox(height: s.h(20)),

          AppTextField(
            controller: _groupNameController,
            hintText: 'Group Name',
          ),

          SizedBox(height: s.h(30)),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    'Cancel',
                    style: AppTextStyles.buttonText(18).copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),

              SizedBox(width: s.w(12)),

              Expanded(
                child: SizedBox(
                  height: s.h(38),
                  child:AppButton(
                    text: 'Create',
                    width: double.infinity,
                    height: s.h(38),
                    borderRadius: BorderRadius.circular(30),
                    showShadow: false,
                    onPressed: () async {
                      final groupName = _groupNameController.text.trim();

                      if (groupName.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Please enter a group name'),
                          ),
                        );
                        return;
                      }

                      try {
                        await context.read<GroupProvider>().createGroup(
                          groupName: groupName,
                        );

                        if (!mounted) return;

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Group created successfully'),
                          ),
                        );
                      } catch (e) {
                        if (!mounted) return;

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(e.toString()),
                          ),
                        );
                      }
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}