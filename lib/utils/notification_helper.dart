import 'dart:developer' as developer;
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../data/models/restaurant.dart';
import '../data/services/api_service.dart';

@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse notificationResponse) {
  developer.log(
    'onDidReceiveBackgroundNotificationResponse: $notificationResponse',
    name: 'NotificationHelper',
  );
}

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin
  _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

  static const String _channelId = 'restaurant_channel';
  static const String _channelName = 'Restaurant Recommendations';
  static const String _channelDescription =
      'Get daily recommendations for amazing restaurants!';

  static Future<void> initialize() async {
    if (kIsWeb) return; // Disable this feature on web
    await _configureLocalTimeZone();

    // Using a default system icon to prevent crashes
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@android:drawable/ic_dialog_info');

    const DarwinInitializationSettings initializationSettingsDarwin =
        DarwinInitializationSettings();

    const InitializationSettings initializationSettings =
        InitializationSettings(
          android: initializationSettingsAndroid,
          iOS: initializationSettingsDarwin,
        );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        developer.log(
          'onDidReceiveNotificationResponse: $details',
          name: 'NotificationHelper',
        );
      },
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
  }

  static Future<void> _configureLocalTimeZone() async {
    if (kIsWeb || Platform.isLinux) return;
    tz.initializeTimeZones();
    final String timeZoneName = await FlutterTimezone.getLocalTimezone();
    tz.setLocalLocation(tz.getLocation(timeZoneName));
  }

  static Future<bool> _requestPermissions() async {
    if (kIsWeb) return false;
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        await openAppSettings();
        return false;
      }
    }
    return true;
  }

  static Future<void> scheduleDailyReminder() async {
    if (kIsWeb) return;
    if (!await _requestPermissions()) return;

    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      11, // 11:00 AM
    );

    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    final restaurant = await _getRestaurantForNotification();
    if (restaurant == null) return;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(
        'Rekomendasi restoran hari ini: ${restaurant.name} di ${restaurant.city}. Jangan lewatkan! '
        'Jelajahi berbagai menu lezat dan nikmati pengalaman kuliner yang tak terlupakan.',
        htmlFormatBigText: true,
        contentTitle: 'Restaurant App Reminder',
        htmlFormatContentTitle: true,
        summaryText: 'Rekomendasi Restoran Harian',
        htmlFormatSummaryText: true,
      ),
    );

    final iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.zonedSchedule(
      0,
      'Restaurant App Reminder',
      'Rekomendasi restoran hari ini: ${restaurant.name}',
      scheduledDate,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    developer.log(
      'Daily reminder scheduled at $scheduledDate',
      name: 'NotificationHelper',
    );
  }

  static Future<Restaurant?> _getRestaurantForNotification() async {
    try {
      final apiService = ApiService();
      final restaurants = await apiService.getRestaurants();
      if (restaurants.isNotEmpty) {
        return (restaurants..shuffle()).first;
      }
    } catch (e) {
      developer.log(
        'Error fetching restaurant for notification: $e',
        name: 'NotificationHelper',
      );
    }
    return null;
  }

  static Future<void> cancelDailyReminder() async {
    if (kIsWeb) return;
    await _flutterLocalNotificationsPlugin.cancel(0);
    developer.log('Daily reminder cancelled', name: 'NotificationHelper');
  }

  static Future<void> showInstantTestNotification() async {
    if (kIsWeb) return;
    if (!await _requestPermissions()) return;

    final restaurant = await _getRestaurantForNotification();
    if (restaurant == null) return;

    final androidPlatformChannelSpecifics = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.max,
      priority: Priority.high,
      ticker: 'ticker',
      styleInformation: BigTextStyleInformation(
        'Ini adalah notifikasi test dari Restaurant App. Restoran unggulan hari ini adalah ${restaurant.name} di ${restaurant.city}.',
        htmlFormatBigText: true,
        contentTitle: 'Test Notifikasi',
        htmlFormatContentTitle: true,
        summaryText: 'Test Notifikasi Instan',
        htmlFormatSummaryText: true,
      ),
    );

    final iOSPlatformChannelSpecifics = DarwinNotificationDetails();

    final platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await _flutterLocalNotificationsPlugin.show(
      1, // ID for test notification
      'Test Notifikasi',
      'Rekomendasi test: ${restaurant.name}',
      platformChannelSpecifics,
    );

    developer.log(
      'Instant test notification shown',
      name: 'NotificationHelper',
    );
  }
}
