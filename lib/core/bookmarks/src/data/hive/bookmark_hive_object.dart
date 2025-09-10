// Package imports:
import 'package:hive_ce/hive.dart';

class BookmarkHiveObject extends HiveObject {
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
    required this.realSourceUrl,
    required this.format,
    required this.postId,
    required this.metadata,
  });

  int? booruId;
  DateTime? createdAt;
  DateTime? updatedAt;
  String? thumbnailUrl;
  String? sampleUrl;
  String? originalUrl;
  String? sourceUrl;
  double? width;
  double? height;
  String? md5;
  List<String>? tags;
  String? realSourceUrl;
  String? format;
  int? postId;
  Map<String, String>? metadata;
}
