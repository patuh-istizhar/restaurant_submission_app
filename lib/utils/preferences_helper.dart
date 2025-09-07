import 'package:shared_preferences/shared_preferences.dart';

class PreferencesHelper {
  static const String _themeKey = 'theme_mode';
  static const String _reminderKey = 'daily_reminder';

  static Future<bool> saveThemeMode(bool isDarkMode) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_themeKey, isDarkMode);
  }

  static Future<bool> getThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_themeKey) ?? false;
  }

  static Future<bool> saveDailyReminderSetting(bool isEnabled) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setBool(_reminderKey, isEnabled);
  }

  static Future<bool> getDailyReminderSetting() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_reminderKey) ?? false;
  }
}
