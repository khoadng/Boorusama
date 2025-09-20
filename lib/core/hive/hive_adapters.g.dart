// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'hive_adapters.dart';

// **************************************************************************
// AdaptersGenerator
// **************************************************************************

class FavoriteTagHiveObjectAdapter extends TypeAdapter<FavoriteTagHiveObject> {
  @override
  final typeId = 2;

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
      queryType: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteTagHiveObject obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.labels)
      ..writeByte(4)
      ..write(obj.queryType);
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

class BlacklistedTagHiveObjectAdapter
    extends TypeAdapter<BlacklistedTagHiveObject> {
  @override
  final typeId = 3;

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

class BookmarkHiveObjectAdapter extends TypeAdapter<BookmarkHiveObject> {
  @override
  final typeId = 4;

  @override
  BookmarkHiveObject read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BookmarkHiveObject(
      booruId: (fields[0] as num?)?.toInt(),
      createdAt: fields[1] as DateTime?,
      updatedAt: fields[2] as DateTime?,
      thumbnailUrl: fields[3] as String?,
      sampleUrl: fields[4] as String?,
      originalUrl: fields[5] as String?,
      sourceUrl: fields[6] as String?,
      width: (fields[7] as num?)?.toDouble(),
      height: (fields[8] as num?)?.toDouble(),
      md5: fields[9] as String?,
      tags: (fields[10] as List?)?.cast<String>(),
      realSourceUrl: fields[11] as String?,
      format: fields[12] as String?,
      postId: (fields[13] as num?)?.toInt(),
      metadata: (fields[14] as Map?)?.cast<String, String>(),
    );
  }

  @override
  void write(BinaryWriter writer, BookmarkHiveObject obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.booruId)
      ..writeByte(1)
      ..write(obj.createdAt)
      ..writeByte(2)
      ..write(obj.updatedAt)
      ..writeByte(3)
      ..write(obj.thumbnailUrl)
      ..writeByte(4)
      ..write(obj.sampleUrl)
      ..writeByte(5)
      ..write(obj.originalUrl)
      ..writeByte(6)
      ..write(obj.sourceUrl)
      ..writeByte(7)
      ..write(obj.width)
      ..writeByte(8)
      ..write(obj.height)
      ..writeByte(9)
      ..write(obj.md5)
      ..writeByte(10)
      ..write(obj.tags)
      ..writeByte(11)
      ..write(obj.realSourceUrl)
      ..writeByte(12)
      ..write(obj.format)
      ..writeByte(13)
      ..write(obj.postId)
      ..writeByte(14)
      ..write(obj.metadata);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BookmarkHiveObjectAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
