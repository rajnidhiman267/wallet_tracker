import 'package:flutter/material.dart';
import 'package:tracker_app/core/theme/app_color.dart';

import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/core/theme/app_text_theme.dart';

class LightTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    scaffoldBackgroundColor: const Color(0xFFF5F7FA),
    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryButtonColor,
      secondary: AppColors.gradientStart,
      surface: Colors.white,
      error: AppColors.dangerColor,
    ),
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: AppColors.primaryDark),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.primaryDark,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.bgTextFieldColor,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.primaryButtonColor,
          width: 1.5,
        ),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.hintTextColor,
      ),
    ),
    textTheme: AppTextTheme.lightTextTheme,
  );
}
