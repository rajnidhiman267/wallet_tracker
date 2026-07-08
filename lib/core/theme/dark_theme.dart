import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tracker_app/core/theme/app_text_theme.dart';
import 'app_color.dart';

class DarkTheme {
  static ThemeData theme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.primaryDark,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.gradientStart,
      secondary: AppColors.gradientEnd,
      surface: AppColors.darkCard,
      error: AppColors.dangerColor,
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkCard,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      centerTitle: false,
      iconTheme: const IconThemeData(color: Colors.white),
      titleTextStyle: GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.darkBorder),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: AppColors.gradientStart,
          width: 1.5,
        ),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: 14,
        color: AppColors.hintTextColor,
      ),
    ),
    textTheme: AppTextTheme.darkTextTheme,
  );
}
