import 'package:flutter/material.dart';
import 'package:noe/pages/home_page.dart';
import 'package:noe/database/reminder_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await ReminderService.init();

  runApp(const MyApp());
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
