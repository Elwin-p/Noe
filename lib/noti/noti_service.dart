import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotiService {
  final notificationsPlugin = FlutterLocalNotificationsPlugin();

  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  //initialize

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const initSettings = InitializationSettings(android: initSettingsAndroid);

    await notificationsPlugin.initialize(initSettings);
  }

  //notification detail setup
  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notification',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
      ),
    );
  }

  //show notification
  Future<void> showNotification({
    int id = 0,
    String? title,
    String? body,
  }) async {
    return notificationsPlugin.show(id, title, body, notificationDetails());
  }

  Future<void> scheduleHourlyNotifications() async {
    await notificationsPlugin.cancelAll();

    for (int hour = 6; hour <= 23; hour++) {
      final tz.TZDateTime scheduled = _nextInstanceOfHour(hour);

      // Schedule with slight delay to avoid blocking UI
      await Future.delayed(Duration(milliseconds: 100));

      await notificationsPlugin.zonedSchedule(
        hour,
        '20 years',
        "It's ${_formatHourLabel(hour)} - stay focused!",
        scheduled,
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time,
      );
    }
  }

  tz.TZDateTime _nextInstanceOfHour(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
    );
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  String _formatHourLabel(int hour) {
    final h = hour > 12 ? hour - 12 : hour;
    final suffix = hour >= 12 ? 'PM' : 'AM';
    return '$h $suffix';
  }
}
