import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/app_scaler.dart';
import '../../models/group_model.dart';
import '../../providers/group_provider.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_text_field.dart';
import 'group_screen.dart';

class JoinGroupSheet extends StatefulWidget {
  const JoinGroupSheet({super.key});

  @override
  State<JoinGroupSheet> createState() => _JoinGroupSheetState();
}

class _JoinGroupSheetState extends State<JoinGroupSheet> {
  final TextEditingController _inviteCodeController =
  TextEditingController();

  bool _isJoining = false;
  String? _errorMessage;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    super.dispose();
  }

  Future<void> _joinGroup() async {
    final inviteCode = _inviteCodeController.text.trim();

    // ------------------------------------------------------------
    // Validate empty invite code
    // ------------------------------------------------------------

    if (inviteCode.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter an invite code.';
      });
      return;
    }

    setState(() {
      _isJoining = true;
      _errorMessage = null;
    });

    try {
      final GroupModel joinedGroup =
      await context.read<GroupProvider>().joinGroup(
        inviteCode: inviteCode,
      );

      if (!mounted) return;

      // ----------------------------------------------------------
      // Close the bottom sheet
      // ----------------------------------------------------------

      Navigator.pop(context);

      // ----------------------------------------------------------
      // Navigate directly to the joined group
      // ----------------------------------------------------------

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => GroupScreen(
            group: joinedGroup,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      String errorMessage = e.toString();

      if (errorMessage.startsWith('Exception: ')) {
        errorMessage =
            errorMessage.substring('Exception: '.length);
      }

      setState(() {
        _errorMessage = errorMessage;
        _isJoining = false;
      });
    }
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
            'Join Group',
            style: Theme.of(context).textTheme.titleLarge,
          ),

          SizedBox(height: s.h(20)),

          AppTextField(
            controller: _inviteCodeController,
            hintText: 'Invite Code',
          ),

          // --------------------------------------------------------
          // Error message
          // --------------------------------------------------------

          if (_errorMessage != null) ...[
            SizedBox(height: s.h(8)),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: s.w(4),
              ),
              child: Text(
                _errorMessage!,
                style: TextStyle(
                  color: Colors.redAccent,
                  fontSize: s.sp(13),
                ),
              ),
            ),
          ],

          SizedBox(height: s.h(30)),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _isJoining
                      ? null
                      : () => Navigator.pop(context),
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
                  child: AppButton(
                    text: _isJoining ? 'Joining...' : 'Join',
                    width: double.infinity,
                    height: s.h(38),
                    borderRadius: BorderRadius.circular(30),
                    showShadow: false,
                    onPressed: _isJoining ? null : _joinGroup,
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