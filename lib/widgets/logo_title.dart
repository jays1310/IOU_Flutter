import 'package:flutter/material.dart';
import '../core/theme/app_text_styles.dart';
class LogoTitle extends StatelessWidget {
  const LogoTitle({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 111,
      height: 122,
      child: Center(
        child: Text(
          "I Owe\nYou",
          textAlign: TextAlign.center,
          style: AppTextStyles.logoTitle,
        ),
      ),
    );
  }
}