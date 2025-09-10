// Package imports:
import 'package:collection/collection.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import '../../types/blacklisted_tag.dart';
import '../../types/blacklisted_tag_repository.dart';
import 'converter.dart';
import 'tag_hive_object.dart';

class HiveBlacklistedTagRepository implements GlobalBlacklistedTagRepository {
  static const _boxName = 'blacklisted_tags';

  late Box<BlacklistedTagHiveObject> _box;

  Future<void> init(String path) async {
    _box = await Hive.openBox<BlacklistedTagHiveObject>(_boxName, path: path);
  }

  @override
  Future<BlacklistedTag?> addTag(String tag) async {
    final existingTag = _box.values.firstWhereOrNull((e) => e.name == tag);

    if (existingTag != null) return null;

    final createdDate = DateTime.now();
    final obj = BlacklistedTagHiveObject(
      name: tag,
      isActive: true,
      createdDate: createdDate,
      updatedDate: createdDate,
    );
    final index = await _box.add(obj);
    return convertFromHiveObject(obj).copyWith(id: index);
  }

  @override
  Future<List<BlacklistedTag>> addTags(List<BlacklistedTag> tags) async {
    final addedTags = <BlacklistedTag>[];
    final now = DateTime.now();

    for (final tag in tags) {
      final existingTag = _box.values.firstWhereOrNull(
        (e) => e.name == tag.name,
      );
      if (existingTag != null) continue;

      final obj = BlacklistedTagHiveObject(
        name: tag.name,
        isActive: tag.isActive,
        createdDate: now,
        updatedDate: now,
      );
      final index = await _box.add(obj);
      addedTags.add(convertFromHiveObject(obj).copyWith(id: index));
    }

    return addedTags;
  }

  @override
  Future<void> removeTag(int tagId) async {
    await _box.delete(tagId);
  }

  @override
  Future<List<BlacklistedTag>> getBlacklist() async {
    return _box.values.map(convertFromHiveObject).toList();
  }

  @override
  Future<BlacklistedTag> updateTag(int tagId, String newTag) async {
    final obj = _box.get(tagId)!;
    final updatedDate = DateTime.now();

    obj
      ..name = newTag
      ..updatedDate = updatedDate;

    await _box.put(tagId, obj);
    return convertFromHiveObject(obj);
  }
}
