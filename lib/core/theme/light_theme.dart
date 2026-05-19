 
import 'package:flutter/material.dart';
import 'package:tracker_app/core/theme/app_color.dart';
 
import 'app_text_theme.dart';

class LightTheme {

  static ThemeData theme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.light,

    scaffoldBackgroundColor: AppColors.primaryDark,

    colorScheme: const ColorScheme.light(
      primary: AppColors.primaryDark,
    ),

    textTheme: AppTextTheme.lightTextTheme,
  );
}