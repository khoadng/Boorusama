// Project imports:
import '../../local/types.dart';
import '../../tag/types.dart';
import 'tag_type_store.dart';

extension TagTypeStoreX on TagTypeStore {
  Future<void> saveTagIfNotExist(
    String siteUrl,
    List<Tag> tags,
  ) async {
    final tagInfos = tags
        .map(
          (tag) => TagInfo.fromTag(
            siteHost: siteUrl,
            tag: tag,
          ),
        )
        .toList();

    await saveOrUpdateTagsBatch(tagInfos);
  }
}
