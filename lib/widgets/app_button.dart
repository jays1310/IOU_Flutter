import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_text_styles.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final BorderRadiusGeometry? borderRadius;
  final bool showShadow;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    required this.width,
    required this.height,
    this.isLoading = false,
    this.borderRadius,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: borderRadius ?? BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.accent,
              AppColors.primary,
            ],
          ),
          boxShadow: showShadow
              ? const [
            BoxShadow(
              color: Color.fromARGB(45, 138, 75, 220),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ]
              : [],
        ),
        child: Center(
          child: isLoading
              ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(
                Colors.white,
              ),
            ),
          )
              : Text(
            text,
            style: AppTextStyles.buttonText(18),
          ),
        ),
      ),
    );
  }
}