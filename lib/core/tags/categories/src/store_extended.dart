// Project imports:
import '../../../boorus/booru/booru.dart';
import '../../tag/tag.dart';
import 'tag_type_store.dart';

extension TagTypeStoreX on TagTypeStore {
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
}
