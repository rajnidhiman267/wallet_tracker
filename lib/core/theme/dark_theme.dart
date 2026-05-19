 

import 'package:flutter/material.dart';
import 'app_color.dart';
 import 'app_text_theme.dart';

class DarkTheme {

  static ThemeData theme = ThemeData(
    useMaterial3: true,

    brightness: Brightness.dark,

    scaffoldBackgroundColor: AppColors.primaryDark,

    colorScheme: const ColorScheme.dark(
      primary: AppColors.primaryDark,
    ),

    textTheme: AppTextTheme.darkTextTheme,
  );
}