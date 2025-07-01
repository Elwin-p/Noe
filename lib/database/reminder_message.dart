import 'package:hive/hive.dart';
import 'package:intl/intl.dart';

part 'reminder_message.g.dart';

@HiveType(typeId: 0)
class ReminderMessage extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String text;

  @HiveField(2)
  DateTime timestamp;

  @HiveField(3)
  bool isCompleted;

  ReminderMessage({
    required this.id,
    required this.text,
    required this.timestamp,
    this.isCompleted = false,
  });

  static String generateId() {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final random = DateTime.now().microsecond;
    return '${timestamp}_${random}';
  }

  Map<String, String> toMap() {
    return {
      'id': id,
      'text': text,
      'timestamp': DateFormat('yyyy-MM-dd     kk:mm').format(timestamp),
      'isCompleted': isCompleted.toString(),
    };
  }

  factory ReminderMessage.fromMap(Map<String, String> map) {
    return ReminderMessage(
      id: map['id'] ?? generateId(),
      text: map['text'] ?? '',
      timestamp: _parseTimestamp(map['timestamp'] ?? ''),
      isCompleted: map['isCompleted']?.toLowerCase() == 'true',
    );
  }

  static DateTime _parseTimestamp(String timestampStr) {
    try {
      return DateFormat('yyyy-MM-dd     kk:mm').parse(timestampStr);
    } catch (e) {
      try {
        return DateTime.parse(timestampStr);
      } catch (e) {
        return DateTime.now();
      }
    }
  }
}
