// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'search_history_hive_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SearchHistoryHiveObjectAdapter
    extends TypeAdapter<SearchHistoryHiveObject> {
  @override
  final int typeId = 1;

  @override
  SearchHistoryHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SearchHistoryHiveObject(
      query: fields[0] as String,
      createdAt: fields[1] as DateTime,
      searchCount: fields[2] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, SearchHistoryHiveObject obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.query)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.searchCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SearchHistoryHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
