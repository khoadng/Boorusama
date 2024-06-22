// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/tags/tags.dart';

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
    List<String>? labels,
  }) async {
    final now = DateTime.now();
    final obj = FavoriteTagHiveObject(
      name: name,
      createdAt: now,
      updatedAt: now,
      labels: labels,
    );

    await box.put(obj.name, obj);

    return favoriteTagHiveObjectToFavoriteTag(obj);
  }

  @override
  Future<FavoriteTag?> updateFirst(String name, FavoriteTag tag) async {
    final t = tag.copyWith(
      updatedAt: () => DateTime.now(),
    );
    final obj = favoriteTagToFavoriteTagHiveObject(t);

    final old = box.values.firstWhere((e) => e.name == name);

    await box.put(old.name, obj);

    return favoriteTagHiveObjectToFavoriteTag(obj);
  }

  @override
  Future<List<FavoriteTag>> createFrom(List<FavoriteTag> tags) async {
    final data = <FavoriteTag>[];

    for (final tag in tags) {
      data.add(
        await create(
          name: tag.name,
          labels: tag.labels,
        ),
      );
    }

    return data;
  }
}
