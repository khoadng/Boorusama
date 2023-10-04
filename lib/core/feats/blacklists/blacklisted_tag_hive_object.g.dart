// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'blacklisted_tag_hive_object.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BlacklistedTagHiveObjectAdapter
    extends TypeAdapter<BlacklistedTagHiveObject> {
  @override
  final int typeId = 3;

  @override
  BlacklistedTagHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BlacklistedTagHiveObject(
      name: fields[0] as String,
      isActive: fields[1] as bool,
      createdDate: fields[2] as DateTime,
      updatedDate: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, BlacklistedTagHiveObject obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.isActive)
      ..writeByte(2)
      ..write(obj.createdDate)
      ..writeByte(3)
      ..write(obj.updatedDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BlacklistedTagHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
