// Package imports:
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../../../search/selected_tags/tag.dart';
import '../types/favorite_tag.dart';

class FavoriteTagHiveObject extends HiveObject {
  FavoriteTagHiveObject({
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    required this.labels,
    this.queryType,
  });

  String name;
  DateTime createdAt;
  DateTime? updatedAt;
  List<String>? labels;
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
