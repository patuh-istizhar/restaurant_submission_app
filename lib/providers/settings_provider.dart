import 'package:flutter/material.dart';

import '../utils/notification_helper.dart';
import '../utils/preferences_helper.dart';

class SettingsProvider with ChangeNotifier {
  SettingsProvider() {
    loadSettings();
  }

  bool _isDailyReminderEnabled = false;
  bool get isDailyReminderEnabled => _isDailyReminderEnabled;

  // Dihapus: bool get isLoading => _isLoading;

  Future<void> loadSettings() async {
    _isDailyReminderEnabled = await PreferencesHelper.getDailyReminderSetting();
    notifyListeners();
  }

  Future<void> setDailyReminder(bool isEnabled) async {
    // Optimistic Update: Update UI immediately
    _isDailyReminderEnabled = isEnabled;
    notifyListeners();

    try {
      await PreferencesHelper.saveDailyReminderSetting(isEnabled);

      if (isEnabled) {
        await NotificationHelper.scheduleDailyReminder();
      } else {
        await NotificationHelper.cancelDailyReminder();
      }
    } catch (e) {
      // Revert on error
      _isDailyReminderEnabled = !isEnabled;
      notifyListeners();
      // Optional: re-throw the error if you want to show a message in the UI
      rethrow;
    }
  }
}
