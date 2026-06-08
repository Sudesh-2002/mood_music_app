// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mood_history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MoodHistoryModelAdapter extends TypeAdapter<MoodHistoryModel> {
  @override
  final int typeId = 2;

  @override
  MoodHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoodHistoryModel(
      id: fields[0] as String,
      moodName: fields[1] as String,
      confidence: fields[2] as double,
      detectedAt: fields[3] as DateTime,
      songPlayed: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MoodHistoryModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.moodName)
      ..writeByte(2)
      ..write(obj.confidence)
      ..writeByte(3)
      ..write(obj.detectedAt)
      ..writeByte(4)
      ..write(obj.songPlayed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoodHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
