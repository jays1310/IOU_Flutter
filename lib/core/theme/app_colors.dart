import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF070220);
  static const Color primary = Color(0xFFB14EFF);
  static const Color accent = Color(0xFFE46CFF);
  static const Color card = Color(0xFF1A0F2D);
  static const Color white = Colors.white;
  static const Color grey = Color(0xFF9E9E9E);
  static const Color success = Color(0xFF4CAF50);
  static const Color error = Color(0xFFE53935);

  static const Color groupBackground = Color(0xFFA667EC);

  static const Color toolbarBackground = Color(0xFF2E2275);

  // ---------------------------------------------------------
  // IOU DARK PURPLE SCREEN GRADIENT
  // ---------------------------------------------------------

  static const LinearGradient screenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      Color(0xFF070220),
      Color(0xFF0D0626),
      Color(0xFF170A35),
      Color(0xFF09021F),
    ],
    stops: [
      0.0,
      0.35,
      0.70,
      1.0,
    ],
  );
}
