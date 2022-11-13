// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/boorus/booru.dart';
import 'package:boorusama/common/collection_utils.dart';
import 'package:boorusama/core/domain/tags/favorite_tag.dart';

part 'favorite_tag_hive_object.g.dart';

@HiveType(typeId: 2)
class FavoriteTagHiveObject {
  FavoriteTagHiveObject({
    required this.name,
    required this.createdAt,
    required this.type,
  });

  @HiveField(0)
  String name;

  @HiveField(1)
  DateTime createdAt;

  @HiveField(2)
  int type;
}

FavoriteTag favoriteTagHiveObjectToFavoriteTag(FavoriteTagHiveObject obj) {
  return FavoriteTag(
    name: obj.name,
    createdAt: obj.createdAt,
    type: BooruType.values.getOrNull(obj.type) ?? BooruType.safebooru,
  );
}

FavoriteTagHiveObject favoriteTagToFavoriteTagHiveObject(FavoriteTag tag) {
  return FavoriteTagHiveObject(
    name: tag.name,
    createdAt: tag.createdAt,
    type: tag.type.index,
  );
}
