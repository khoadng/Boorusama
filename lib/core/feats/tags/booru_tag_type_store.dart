// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import 'package:boorusama/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/core/feats/boorus/booru.dart';
import 'package:boorusama/foundation/path.dart';
import 'tag.dart';

/// This class is a kitchen sink for all sites, use as last resort
class BooruTagTypeStore {
  BooruTagTypeStore();

  Box<String>? _box;

  static String get dataKey => 'general_tag_type_store_v1';

  static Future<String> getBoxPath() async {
    final dir = await getApplicationSupportDirectory();
    return join(dir.path, '$dataKey.hive');
  }

  Future<Box<String>> getBox() async {
    if (_box != null) {
      return Future.value(_box!);
    }

    final dir = await getApplicationSupportDirectory();

    _box = await Hive.openBox(dataKey, path: dir.path);
    return _box!;
  }

  Future<void> save(BooruType booruType, String tag, String category) async {
    final box = await getBox();
    final keyForSpecificBooru = '${booruType.name}%%%$tag';
    final keyForGeneralBooru = 'generic%%%$tag';
    await box.put(keyForSpecificBooru, category.toString());
    await box.put(keyForGeneralBooru, category.toString());
  }

  Future<String?> get(BooruType booruType, String tag) async {
    final box = await getBox();

    // Get key for specific booru first
    final keyForSpecificBooru = '${booruType.name}%%%$tag';
    final dataForSpecificBooru = box.get(keyForSpecificBooru);
    if (dataForSpecificBooru != null) {
      return dataForSpecificBooru;
    }

    // Get key for general booru
    final keyForGeneralBooru = 'generic%%%$tag';
    final dataForGeneralBooru = box.get(keyForGeneralBooru);

    return dataForGeneralBooru;
  }

  Future<void> clear() async {
    final box = await getBox();
    await box.clear();
  }
}

extension BooruTagTypeStoreX on BooruTagTypeStore {
  Future<void> saveIfNotExist<T>(
    BooruType booruType,
    List<T> tags,
    String Function(T tag) keyBuilder,
    String? Function(T tag) categoryBuilder,
  ) async {
    for (final item in tags) {
      final key = keyBuilder(item);
      final category = categoryBuilder(item);

      if (category == null) continue;

      final cached = await get(booruType, key);

      if (cached == null) {
        await save(booruType, key, category);
      }
    }
  }

  Future<void> saveTagIfNotExist(
    BooruType booruType,
    List<Tag> tags,
  ) =>
      saveIfNotExist(
        booruType,
        tags,
        (tag) => tag.rawName,
        (tag) => tag.category.name,
      );

  Future<void> saveAutocompleteIfNotExist(
    BooruType booruType,
    List<AutocompleteData> tags,
  ) =>
      saveIfNotExist(
        booruType,
        tags,
        (tag) => tag.value,
        (tag) => tag.category,
      );
}
