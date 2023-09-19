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
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteTagHiveObject obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdAt);
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
