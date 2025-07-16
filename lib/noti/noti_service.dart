import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;
// import 'package:workmanager/workmanager.dart';

class NotiService {
  static final NotiService _instance = NotiService._internal();
  factory NotiService() => _instance;
  NotiService._internal();

  final notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  Future<void> initNotification() async {
    if (_isInitialized) return;

    const initSettingsAndroid = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const initSettingsIOS = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const initSettings = InitializationSettings(
      android: initSettingsAndroid,
      iOS: initSettingsIOS,
    );

    await notificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        print(
          'Notification tapped: ID=${response.id}, Payload=${response.payload}',
        );
      },
    );

    final androidPlugin =
        notificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();
    if (androidPlugin != null) {
      final notificationGranted =
          await androidPlugin.requestNotificationsPermission();
      print('Android notification permission granted: $notificationGranted');
      final exactAlarmGranted =
          await androidPlugin.requestExactAlarmsPermission();
      print('Android exact alarm permission granted: $exactAlarmGranted');
    }

    _isInitialized = true;
    print('Notification initialization: $_isInitialized');

    final launchDetails =
        await notificationsPlugin.getNotificationAppLaunchDetails();
    print('App launch details: $launchDetails');
  }

  NotificationDetails notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_channel_id',
        'Daily Notification',
        channelDescription: 'Daily Notification Channel',
        importance: Importance.max,
        priority: Priority.high,
        showWhen: true,
        enableVibration: true,
        playSound: true,
        channelShowBadge: true,
        enableLights: true,
        ticker: 'Daily Notification',
        icon: 'ic_stat_ic_notification',
      ),
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );
  }

  Future<void> showMidnightCountdownNotification() async {
    final now = DateTime.now();
    final midnight = DateTime(now.year, now.month, now.day + 1);
    final diff = midnight.difference(now);

    final hours = diff.inHours;
    final minutes = diff.inMinutes.remainder(60);
    final seconds = diff.inSeconds.remainder(60);

    final message = '$hours hrs $minutes mins $seconds secs until day dies';

    await notificationsPlugin.show(
      1002,
      "Time Doesn't Wait",
      message,
      notificationDetails(),
      payload: 'midnight_countdown',
    );
  }
}
