import 'package:flutter/foundation.dart';

import '../utils/preferences_helper.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    loadSettings();
  }

  bool _isDailyReminderEnabled = false;
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;

  Future<void> loadSettings() async {
    _isDailyReminderEnabled = await PreferencesHelper.getDailyReminderSetting();
    notifyListeners();
  }

  Future<void> setDailyReminder(bool isEnabled) async {
    _isDailyReminderEnabled = isEnabled;
    await PreferencesHelper.saveDailyReminderSetting(isEnabled);
    notifyListeners();
  }
}
