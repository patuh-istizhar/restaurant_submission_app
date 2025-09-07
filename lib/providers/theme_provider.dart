import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../utils/preferences_helper.dart';

class ThemeProvider with ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  Future<void> loadTheme() async {
    try {
      final isDark = await PreferencesHelper.getThemeMode();
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
      notifyListeners();
    } catch (e) {
      _themeMode = ThemeMode.light;
      if (kDebugMode) debugPrint('Failed to load theme: $e');
    }
  }

  Future<void> toggleTheme() async {
    final newMode = _themeMode == ThemeMode.light
        ? ThemeMode.dark
        : ThemeMode.light;

    await setTheme(newMode);
  }

  Future<void> setTheme(ThemeMode themeMode) async {
    _themeMode = themeMode;

    try {
      await PreferencesHelper.saveThemeMode(themeMode == ThemeMode.dark);
    } catch (e) {
      if (kDebugMode) debugPrint('Failed to save theme mode: $e');
    }

    notifyListeners();
  }
}
