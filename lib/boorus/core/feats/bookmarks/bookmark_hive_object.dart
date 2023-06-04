// Package imports:
import 'package:hive/hive.dart';

part 'bookmark_hive_object.g.dart';

@HiveType(typeId: 4)
class BookmarkHiveObject extends HiveObject {
  @HiveField(0)
  int? booruId;

  @HiveField(1)
  DateTime? createdAt;

  @HiveField(2)
  DateTime? updatedAt;

  @HiveField(3)
  String? thumbnailUrl;

  @HiveField(4)
  String? sampleUrl;

  @HiveField(5)
  String? originalUrl;

  @HiveField(6)
  String? sourceUrl;

  @HiveField(7)
  double? width;

  @HiveField(8)
  double? height;

  @HiveField(9)
  String? md5;

  @HiveField(10)
  List<String>? tags;

  BookmarkHiveObject({
    required this.booruId,
    required this.createdAt,
    required this.updatedAt,
    required this.thumbnailUrl,
    required this.sampleUrl,
    required this.originalUrl,
    required this.sourceUrl,
    required this.width,
    required this.height,
    required this.md5,
    required this.tags,
  });
}
