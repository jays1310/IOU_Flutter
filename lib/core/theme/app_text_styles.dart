import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTextStyles {
  AppTextStyles._();

  static TextStyle logoTitle = GoogleFonts.arOneSans(
    color: Colors.white,
    fontSize: 34,
    fontWeight: FontWeight.w500,
    height: 1.05,
  );

  static TextStyle getStartedWhite(double fontSize) => GoogleFonts.raleway(
    color: Colors.white,
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static TextStyle getStartedPurple(double fontSize) => GoogleFonts.raleway(
    color: AppColors.accent,
    fontSize: fontSize,
    fontWeight: FontWeight.w500,
    height: 1.0,
  );

  static TextStyle buttonText(double fontSize) => GoogleFonts.raleway(
    color: Colors.white,
    fontSize: fontSize,
    fontWeight: FontWeight.w600,
    letterSpacing: 0.3,
  );

  static TextStyle welcomeText(double fontSize) => GoogleFonts.raleway(
    color: Colors.white,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
  );

  static TextStyle welcomeBackText(double fontSize) => GoogleFonts.raleway(
    color: AppColors.accent,
    fontSize: fontSize,
    fontWeight: FontWeight.w700,
  );
}