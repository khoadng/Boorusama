// Package imports:
import 'package:hive/hive.dart';

// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../../foundation/path.dart';
import '../../../foundation/platform.dart';
import 'tag_type_store.dart';

/// This class is a kitchen sink for all sites, use as last resort
class BooruTagTypeStore implements TagTypeStore {
  BooruTagTypeStore();

  Box<String>? _box;

  static String get dataKey => 'general_tag_type_store_v2';

  static Future<String> getBoxPath(String dirPath) async {
    return join(dirPath, '$dataKey.hive');
  }

  Future<Box<String>> getBox() async {
    if (_box != null) {
      return Future.value(_box!);
    }

    //FIXME: should get from provider
    final dir = isAndroid()
        ? await getApplicationDocumentsDirectory()
        : await getApplicationSupportDirectory();

    _box = await Hive.openBox(dataKey, path: dir.path);
    return _box!;
  }

  @override
  Future<void> save(BooruType booruType, String tag, String category) async {
    final box = await getBox();
    final keyForSpecificBooru = '${booruType.name}%%%$tag';
    final keyForGeneralBooru = 'generic%%%$tag';
    await box.put(keyForSpecificBooru, category);
    await box.put(keyForGeneralBooru, category);
  }

  @override
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

  @override
  Future<void> clear() async {
    final box = await getBox();
    await box.clear();
  }

  @override
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
      try {
        final cached = await get(booruType, key);

        if (cached == null) {
          await save(booruType, key, category);
        }
      } catch (e) {
        // Ignore error, this is a best effort operation
        // If data is corrupted, we can't do anything
      }
    }
  }
}
