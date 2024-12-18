// Project imports:
import '../../../boorus/booru/booru.dart';

abstract class TagTypeStore {
  Future<void> save(BooruType booruType, String tag, String category);
  Future<String?> get(BooruType booruType, String tag);
  Future<void> clear();

  Future<void> saveIfNotExist<T>(
    BooruType booruType,
    List<T> tags,
    String Function(T tag) keyBuilder,
    String? Function(T tag) categoryBuilder,
  );
}
