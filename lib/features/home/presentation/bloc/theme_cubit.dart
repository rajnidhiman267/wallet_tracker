import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
 

class ThemeCubit extends Cubit<ThemeMode> {
  static const _key = 'theme_mode';

  ThemeCubit() : super(ThemeMode.light) {
    _loadSavedTheme();
  }

  Future<void> _loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_key);
    if (saved == 'dark') {
      emit(ThemeMode.dark);
    } else {
      emit(ThemeMode.light);
    }
  }

  Future<void> toggleTheme() async {
    final prefs = await SharedPreferences.getInstance();
    if (state == ThemeMode.light) {
      emit(ThemeMode.dark);
      await prefs.setString(_key, 'dark');
    } else {
      emit(ThemeMode.light);
      await prefs.setString(_key, 'light');
    }
  }

  bool get isDark => state == ThemeMode.dark;
}