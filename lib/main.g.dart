// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'main.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ToDoTileAdapter extends TypeAdapter<ToDoTile> {
  @override
  final int typeId = 1;

  @override
  ToDoTile read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ToDoTile(
      fields[0] as int,
      fields[1] as String,
      fields[2] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ToDoTile obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.completed);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ToDoTileAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
