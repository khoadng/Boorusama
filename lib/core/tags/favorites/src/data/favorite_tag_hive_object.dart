// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../../search/selected_tags/tag.dart';
import '../types/favorite_tag.dart';

part 'favorite_tag_hive_object.g.dart';

@HiveType(typeId: 2)
class FavoriteTagHiveObject {
  FavoriteTagHiveObject({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
    this.queryType,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime? updatedAt;

  @HiveField(3)
  List<String>? labels;

  @HiveField(4)
  String? queryType;
}

FavoriteTag favoriteTagHiveObjectToFavoriteTag(FavoriteTagHiveObject obj) {
  return FavoriteTag(
    name: obj.name,
    createdAt: obj.createdAt,
    updatedAt: obj.updatedAt,
    labels: obj.labels,
    queryType: parseQueryType(obj.queryType),
  );
}

FavoriteTagHiveObject favoriteTagToFavoriteTagHiveObject(FavoriteTag tag) {
  return FavoriteTagHiveObject(
    name: tag.name,
    createdAt: tag.createdAt,
    updatedAt: tag.updatedAt,
    labels: tag.labels,
    queryType: tag.queryType?.name,
  );
}
