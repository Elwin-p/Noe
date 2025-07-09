import 'package:flutter/material.dart';
import 'package:noe/noti/noti_service.dart';
import 'package:noe/pages/home_page.dart';
import 'package:noe/database/reminder_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Timezone setup
  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation('Asia/Kolkata'));

  // Initialize ReminderService
  await ReminderService.init();

  // Initialize notifications
  final notiService = NotiService();
  await notiService.initNotification();
  if (notiService.isInitialized) {
    await notiService.scheduleHourlyNotifications();
  } else {
    print('Notification initialization failed');
  }

  runApp(const MyApp());

  final runAppDone = DateTime.now();
  print("runApp() returned at: $runAppDone");

  WidgetsBinding.instance.addPostFrameCallback((_) {
    print("First frame rendered at: ${DateTime.now()}");
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      home: const HomePage(),
    );
  }
}
