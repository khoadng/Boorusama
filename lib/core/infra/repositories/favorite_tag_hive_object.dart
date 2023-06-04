// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';

part 'favorite_tag_hive_object.g.dart';

@HiveType(typeId: 2)
class FavoriteTagHiveObject {
  FavoriteTagHiveObject({
    required this.name,
    required this.createdAt,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;
}

FavoriteTag favoriteTagHiveObjectToFavoriteTag(FavoriteTagHiveObject obj) {
  return FavoriteTag(
    name: obj.name,
    createdAt: obj.createdAt,
  );
}

FavoriteTagHiveObject favoriteTagToFavoriteTagHiveObject(FavoriteTag tag) {
  return FavoriteTagHiveObject(
    name: tag.name,
    createdAt: tag.createdAt,
  );
}
