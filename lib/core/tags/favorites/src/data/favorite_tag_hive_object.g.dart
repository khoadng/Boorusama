// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_tag_hive_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteTagHiveObjectAdapter extends TypeAdapter<FavoriteTagHiveObject> {
  @override
  final int typeId = 2;

  @override
  FavoriteTagHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteTagHiveObject(
      name: fields[0] as String,
      createdAt: fields[1] as DateTime,
      updatedAt: fields[2] as DateTime?,
      labels: (fields[3] as List?)?.cast<String>(),
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteTagHiveObject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.labels);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteTagHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
