import 'dart:async';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:workmanager/workmanager.dart';

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

  Future<void> scheduleHourlyNotifications() async {
    await notificationsPlugin.cancelAll();
    print('Cancelled all notifications at: ${DateTime.now()}');

    // Immediate notification
    print('Showing immediate test notification');
    try {
      await notificationsPlugin.show(
        998,
        'Immediate Test',
        'This appeared immediately!',
        notificationDetails(),
        payload: 'immediate_test',
      );
      print('Immediate test notification triggered');
    } catch (e) {
      print('Error showing immediate notification: $e');
    }

    // periodicallyShow test (every 5 minutes)
    print('Preparing periodicallyShow test');
    try {
      await notificationsPlugin.periodicallyShow(
        999,
        '5-Minute Test',
        'This is a repeating test every 5 minutes!',
        RepeatInterval.everyMinute, // 5-minute interval for testing
        notificationDetails(),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: 'periodic_test',
      );
      print('periodicallyShow test scheduled successfully');
    } catch (e) {
      print('Error scheduling periodicallyShow test: $e');
    }

    // Workmanager for hourly notifications
    print('Setting up workmanager for hourly notifications');
    try {
      await Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      await Workmanager().registerPeriodicTask(
        'hourly_notification_task',
        'hourly_notification',
        frequency: const Duration(hours: 1),
        initialDelay: _calculateInitialDelay(),
        constraints: Constraints(
          networkType: NetworkType.notRequired,
          requiresBatteryNotLow: false,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
      );
      print('Workmanager task scheduled successfully');
    } catch (e) {
      print('Error scheduling workmanager task: $e');
    }
  }

  Duration _calculateInitialDelay() {
    final now = tz.TZDateTime.now(tz.local);
    final nextHour = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      now.hour + 1,
    );
    return nextHour.difference(now);
  }
}

String _formatHourLabel(int hour) {
  final h = hour > 12 ? hour - 12 : hour;
  final suffix = hour >= 12 ? 'PM' : 'AM';
  return '$h $suffix';
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    final notificationsPlugin = FlutterLocalNotificationsPlugin();
    final now = tz.TZDateTime.now(tz.local);
    final hour = now.hour;
    print('Workmanager task triggered at: $now');

    if (hour >= 6 && hour <= 23) {
      try {
        await notificationsPlugin.initialize(
          const InitializationSettings(
            android: AndroidInitializationSettings('@mipmap/ic_launcher'),
            iOS: DarwinInitializationSettings(),
          ),
        );
        await notificationsPlugin.show(
          hour,
          '20 years',
          "It's ${_formatHourLabel(hour)} - stay focused!",
          const NotificationDetails(
            android: AndroidNotificationDetails(
              'daily_channel_id',
              'Daily Notification',
              channelDescription: 'Daily Notification Channel',
              importance: Importance.max,
              priority: Priority.high,
              showWhen: true,
              enableVibration: true,
              playSound: true,
            ),
          ),
          payload: 'hourly_$hour',
        );
        print('Workmanager notification for hour $hour triggered');
      } catch (e) {
        print('Error in workmanager notification for hour $hour: $e');
      }
    }
    return Future.value(true);
  });
}

// import 'package:flutter_local_notifications/flutter_local_notifications.dart';
// import 'package:timezone/timezone.dart' as tz;

// class NotiService {
//   final notificationsPlugin = FlutterLocalNotificationsPlugin();

//   bool _isInitialized = false;

//   bool get isInitialized => _isInitialized;

//   // Initialize notifications with permission handling
//   Future<void> initNotification() async {
//     if (_isInitialized) return;

//     const initSettingsAndroid = AndroidInitializationSettings(
//       '@mipmap/ic_launcher',
//     );
//     const initSettingsIOS = DarwinInitializationSettings(
//       requestAlertPermission: true,
//       requestBadgePermission: true,
//       requestSoundPermission: true,
//     );
//     const initSettings = InitializationSettings(
//       android: initSettingsAndroid,
//       iOS: initSettingsIOS,
//     );

//     // Add tap handler
//     await notificationsPlugin.initialize(
//       initSettings,
//       onDidReceiveNotificationResponse: (NotificationResponse response) {
//         print(
//           'Notification tapped: ID=${response.id}, Payload=${response.payload}',
//         );
//       },
//     );

//     final androidPlugin =
//         notificationsPlugin
//             .resolvePlatformSpecificImplementation<
//               AndroidFlutterLocalNotificationsPlugin
//             >();
//     if (androidPlugin != null) {
//       final notificationGranted =
//           await androidPlugin.requestNotificationsPermission();
//       print('Android notification permission granted: $notificationGranted');
//       final exactAlarmGranted =
//           await androidPlugin.requestExactAlarmsPermission();
//       print('Android exact alarm permission granted: $exactAlarmGranted');
//     }

//     final iosPlugin =
//         notificationsPlugin
//             .resolvePlatformSpecificImplementation<
//               IOSFlutterLocalNotificationsPlugin
//             >();
//     if (iosPlugin != null) {
//       final granted = await iosPlugin.requestPermissions(
//         alert: true,
//         badge: true,
//         sound: true,
//       );
//       print('iOS notification permission granted: $granted');
//     }

//     _isInitialized = true;
//     print('Notification initialization: $_isInitialized');
//   }

//   // Notification details
//   NotificationDetails notificationDetails() {
//     return const NotificationDetails(
//       android: AndroidNotificationDetails(
//         'daily_channel_id',
//         'Daily Notification',
//         channelDescription: 'Daily Notification Channel',
//         importance: Importance.max,
//         priority: Priority.high,
//         showWhen: true,
//         enableVibration: true,
//         playSound: true,
//         channelShowBadge: true,
//         enableLights: true,
//         // Ensure foreground notifications show
//         ticker: 'Daily Notification',
//       ),
//       iOS: DarwinNotificationDetails(
//         presentAlert: true,
//         presentBadge: true,
//         presentSound: true,
//       ),
//     );
//   }

//   // Show immediate notification
//   Future<void> showNotification({
//     int id = 0,
//     String? title,
//     String? body,
//   }) async {
//     await notificationsPlugin.show(id, title, body, notificationDetails());
//   }

//   // Schedule hourly notifications

//   //pinne nokam

//   // Future<void> scheduleHourlyNotifications() async {
//   //   await notificationsPlugin.cancelAll();
//   //   print('Cancelled all previous notifications');

//   //   // Try exact scheduling first, fall back to inexact if permission is denied
//   //   bool useExact = true;
//   //   try {
//   //     final androidPlugin = notificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
//   //     final exactPermissionGranted = await androidPlugin?.requestExactAlarmsPermission() ?? false;
//   //     print('Exact alarm permission check: $exactPermissionGranted');
//   //     if (!exactPermissionGranted) {
//   //       useExact = false;
//   //     }
//   //   } catch (e) {
//   //     print('Error checking exact alarm permission: $e');
//   //     useExact = false;
//   //   }

//   //   final scheduleMode = useExact ? AndroidScheduleMode.exactAllowWhileIdle : AndroidScheduleMode.inexactAllowWhileIdle;
//   //   print('Using schedule mode: $scheduleMode');

//   //   for (int hour = 6; hour <= 23; hour++) {
//   //     final tz.TZDateTime scheduled = _nextInstanceOfHour(hour);
//   //     print('Scheduling notification for: $scheduled (ID: $hour)');

//   //     try {
//   //       await notificationsPlugin.zonedSchedule(
//   //         hour,
//   //         '20 years',
//   //         "It's ${_formatHourLabel(hour)} - stay focused!",
//   //         scheduled,
//   //         notificationDetails(),
//   //         androidScheduleMode: scheduleMode,
//   //         matchDateTimeComponents: DateTimeComponents.time,
//   //       );
//   //     } catch (e) {
//   //       print('Error scheduling notification for hour $hour: $e');
//   //       if (e.toString().contains('exact_alarms_not_permitted') && useExact) {
//   //         // Retry with inexact scheduling
//   //         useExact = false;
//   //         print('Retrying with inexact scheduling for hour $hour');
//   //         await notificationsPlugin.zonedSchedule(
//   //           hour,
//   //           '20 years',
//   //           "It's ${_formatHourLabel(hour)} - stay focused!",
//   //           scheduled,
//   //           notificationDetails(),
//   //           androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
//   //           matchDateTimeComponents: DateTimeComponents.time,
//   //         );
//   //       }
//   //     }
//   //   }
//   //   print('Completed scheduling hourly notifications');
//   // }

//   Future<void> scheduleHourlyNotifications() async {
//     await notificationsPlugin.cancelAll();
//     print('Cancelled all notifications at: ${DateTime.now()}');

//     // Immediate notification
//     print('Showing immediate test notification');
//     try {
//       await notificationsPlugin.show(
//         998,
//         'Immediate Test',
//         'This appeared immediately!',
//         notificationDetails(),
//       );
//       print('Immediate test notification triggered');
//     } catch (e) {
//       print('Error showing immediate notification: $e');
//     }

//     // 1-minute notification test
//     print('Preparing 1-minute test notification');
//     try {
//       final androidPlugin =
//           notificationsPlugin
//               .resolvePlatformSpecificImplementation<
//                 AndroidFlutterLocalNotificationsPlugin
//               >();
//       final exactPermissionGranted =
//           await androidPlugin?.requestExactAlarmsPermission() ?? false;
//       print('Exact alarm permission: $exactPermissionGranted');

//       const scheduleMode =
//           AndroidScheduleMode
//               .exactAllowWhileIdle; // Use exact since permission is granted
//       print('Using schedule mode: $scheduleMode');

//       final now = tz.TZDateTime.now(tz.local);
//       final scheduled = now.add(const Duration(seconds: 30));
//       print('Current time: $now, Timezone: ${tz.local.name}');
//       print(
//         'Scheduling 1-minute test for: $scheduled (Unix: ${scheduled.millisecondsSinceEpoch})',
//       );

//       await notificationsPlugin.zonedSchedule(
//         999,
//         '1-Minute Test',
//         'This is a 1-minute test notification!',
//         scheduled,
//         notificationDetails(),
//         androidScheduleMode: scheduleMode,
//         payload: 'test_1min',
//       );
//       print('1-minute test notification scheduled successfully');
//     } catch (e) {
//       print('Error scheduling 1-minute test notification: $e');
//     }
//   }

//   tz.TZDateTime _nextInstanceOfHour(int hour) {
//     final now = tz.TZDateTime.now(tz.local);
//     print('Current time: $now, Timezone: ${tz.local.name}');
//     tz.TZDateTime scheduled = tz.TZDateTime(
//       tz.local,
//       now.year,
//       now.month,
//       now.day,
//       hour,
//     );
//     if (scheduled.isBefore(now)) {
//       scheduled = scheduled.add(const Duration(days: 1));
//     }
//     return scheduled;
//   }

//   String _formatHourLabel(int hour) {
//     final h =
//         hour > 12
//             ? hour - 12
//             : hour == 0
//             ? 12
//             : hour;
//     final suffix = hour >= 12 ? 'PM' : 'AM';
//     return '$h $suffix';
//   }
// }
