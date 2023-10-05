// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/path.dart';

class DanbooruTagCategoryRepository {
  DanbooruTagCategoryRepository({
    required this.config,
  });

  final BooruConfig config;

  Box<String>? _box;

  Future<Box<String>> getBox() async {
    if (_box != null) {
      return Future.value(_box!);
    }

    final dir = await getTemporaryDirectory();

    _box = await Hive.openBox(
        '${Uri.encodeComponent(config.url)}_tag_categories_v1',
        path: dir.path);
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
