import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_color.dart';

/// | NAME           | SIZE |  WEIGHT |  SPACING |             |
/// |----------------|------|---------|----------|-------------|
/// | displayLarge   | 96.0 | light   | -1.5     |             |
/// | displayMedium  | 60.0 | light   | -0.5     |             |
/// | displaySmall   | 48.0 | regular |  0.0     |             |
/// | headlineMedium | 34.0 | regular |  0.25    |             |
/// | headlineSmall  | 24.0 | regular |  0.0     |             |
/// | titleLarge     | 20.0 | medium  |  0.15    |             |
/// | titleMedium    | 16.0 | regular |  0.15    |             |
/// | titleSmall     | 14.0 | medium  |  0.1     |             |
/// | bodyLarge      | 16.0 | regular |  0.5     |             |
/// | bodyMedium     | 14.0 | regular |  0.25    |             |
/// | bodySmall      | 12.0 | regular |  0.4     |             |
/// | labelLarge     | 14.0 | medium  |  1.25    |             |
/// | labelSmall     | 10.0 | regular |  1.5     |             |

class AppTextTheme {
  /// LIGHT TEXT THEME
  static TextTheme lightTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.primaryDark,
    ),

    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryDark,
    ),

    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryDark,
    ),

    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryDark,
    ),

    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.primaryDark,
    ),

    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.hintTextColor,
    ),

    labelLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  );

  /// DARK TEXT THEME
  static TextTheme darkTextTheme = TextTheme(
    headlineLarge: GoogleFonts.poppins(
      fontSize: 32,
      fontWeight: FontWeight.bold,
      color: AppColors.hintTextColor,
    ),

    headlineMedium: GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.hintTextColor,
    ),

    titleLarge: GoogleFonts.poppins(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: AppColors.hintTextColor,
    ),

    bodyLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: AppColors.hintTextColor,
    ),

    bodyMedium: GoogleFonts.poppins(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      color: AppColors.hintTextColor,
    ),

    bodySmall: GoogleFonts.poppins(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: AppColors.bgTextFieldColor,
    ),

    labelLarge: GoogleFonts.poppins(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.black,
    ),
  );
}
