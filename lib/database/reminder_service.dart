import 'package:hive_flutter/hive_flutter.dart';
import 'reminder_message.dart';

class ReminderService {
  static const String _boxName = 'reminders';
  static Box<ReminderMessage>? _box;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ReminderMessageAdapter());
    _box = await Hive.openBox<ReminderMessage>(_boxName);
  }

  static Box<ReminderMessage> get box {
    if (_box == null || !_box!.isOpen) {
      throw Exception('Hive box is not initialized');
    }
    return _box!;
  }

  static Future<void> addReminder(String text) async {
    final reminder = ReminderMessage(
      id: ReminderMessage.generateId(),
      text: text,
      timestamp: DateTime.now(),
    );
    await box.add(reminder);
  }

  static List<ReminderMessage> getAllReminders() {
    return box.values.toList()
      ..sort((a, b) => b.timestamp.compareTo(a.timestamp));
  }

  static Future<void> updateReminder(dynamic key, String newText) async {
    final reminder = box.get(key);
    if (reminder != null) {
      reminder.text = newText;
      await reminder.save();
    }
  }

  static Future<void> deleteReminder(int index) async {
    await box.deleteAt(index);
  }

  static Future<void> toggleCompletion(int index) async {
    final reminder = box.getAt(index);
    if (reminder != null) {
      reminder.isCompleted = !reminder.isCompleted;
      await reminder.save();
    }
  }

  static Future<void> migrateFromMapList(
    List<Map<String, String>> messages,
  ) async {
    for (var message in messages) {
      final reminder = ReminderMessage.fromMap(message);
      await box.add(reminder);
    }
  }

  static List<Map<String, String>> getAsMapList() {
    return getAllReminders().map((reminder) => reminder.toMap()).toList();
  }
}
