// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/domain/tags/favorite_tag.dart';
import 'package:boorusama/core/domain/tags/favorite_tag_repository.dart';
import 'package:boorusama/core/infra/repositories/favorite_tag_hive_object.dart';

class FavoriteTagRepositoryHive implements FavoriteTagRepository {
  FavoriteTagRepositoryHive(this.box);

  final Box<FavoriteTagHiveObject> box;

  @override
  Future<FavoriteTag?> deleteFirst(String name) async {
    try {
      final obj = box.values.firstWhere((e) => e.name == name);

      await box.delete(obj.name);

      return favoriteTagHiveObjectToFavoriteTag(obj);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<FavoriteTag>> get(String name) async {
    return box.values
        .where((e) => e.name == name)
        .map(favoriteTagHiveObjectToFavoriteTag)
        .toList();
  }

  @override
  Future<List<FavoriteTag>> getAll() async {
    return box.values.map(favoriteTagHiveObjectToFavoriteTag).toList();
  }

  @override
  Future<FavoriteTag?> getFirst(String name) async {
    try {
      final obj = box.values.firstWhere((e) => e.name == name);

      return favoriteTagHiveObjectToFavoriteTag(obj);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<FavoriteTag> create({
    required String name,
  }) async {
    final obj = FavoriteTagHiveObject(
      name: name,
      createdAt: DateTime.now(),
    );

    await box.put(obj.name, obj);

    return favoriteTagHiveObjectToFavoriteTag(obj);
  }
}
