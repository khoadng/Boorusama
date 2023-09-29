// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/feats/tags/tags.dart';

class DanbooruTagCategoryRepository {
  Box<String>? _box;

  Future<Box<String>> getBox() async {
    if (_box != null) {
      return Future.value(_box!);
    }

    _box = await Hive.openBox('danbooru_tag_categories_v1');
    return _box!;
  }

  Future<void> save(String tag, TagCategory category) async {
    final box = await getBox();
    await box.put(tag, category.index.toString());
  }

  Future<TagCategory?> get(String tag) async {
    final box = await getBox();
    final data = box.get(tag);
    if (data == null) {
      return null;
    }

    final categoryId = int.tryParse(data);

    if (categoryId == null) {
      return null;
    }

    final category = intToTagCategory(categoryId);

    return category;
  }
}
