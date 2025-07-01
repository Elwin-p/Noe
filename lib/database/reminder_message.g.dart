// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reminder_message.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ReminderMessageAdapter extends TypeAdapter<ReminderMessage> {
  @override
  final int typeId = 0;

  @override
  ReminderMessage read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ReminderMessage(
      id: fields[0] as String,
      text: fields[1] as String,
      timestamp: fields[2] as DateTime,
      isCompleted: fields[3] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ReminderMessage obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.text)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.isCompleted);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReminderMessageAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
