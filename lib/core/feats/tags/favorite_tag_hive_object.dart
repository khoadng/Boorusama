// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

part 'favorite_tag_hive_object.g.dart';

@HiveType(typeId: 2)
class FavoriteTagHiveObject {
  FavoriteTagHiveObject({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  DateTime? updatedAt;

  @HiveField(3)
  List<String>? labels;
}

FavoriteTag favoriteTagHiveObjectToFavoriteTag(FavoriteTagHiveObject obj) {
  return FavoriteTag(
    name: obj.name,
    createdAt: obj.createdAt,
    updatedAt: obj.updatedAt,
    labels: obj.labels,
  );
}

FavoriteTagHiveObject favoriteTagToFavoriteTagHiveObject(FavoriteTag tag) {
  return FavoriteTagHiveObject(
    name: tag.name,
    createdAt: tag.createdAt,
    updatedAt: tag.updatedAt,
    labels: tag.labels,
  );
}
