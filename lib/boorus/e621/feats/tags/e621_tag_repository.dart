// Project imports:
import 'package:boorusama/clients/e621/e621_client.dart';
import 'package:boorusama/clients/e621/types/types.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'e621_tag.dart';
import 'e621_tag_category.dart';

abstract interface class E621TagRepository {
  Future<List<E621Tag>> getTagsWithWildcard(
    String tag, {
    TagSortOrder order = TagSortOrder.count,
  });
}

class E621TagRepositoryApi implements E621TagRepository {
  E621TagRepositoryApi(
    this.client,
    this.booruConfig,
  );

  final E621Client client;
  final BooruConfig booruConfig;

  @override
  Future<List<E621Tag>> getTagsWithWildcard(
    String tag, {
    TagSortOrder order = TagSortOrder.count,
  }) =>
      client
          .getTags(name: tag)
          .then((value) => value.map(e621TagDtoToTag).toList())
          .catchError((e, stackTrace) => <E621Tag>[]);
}

E621Tag e621TagDtoToTag(TagDto dto) {
  return E621Tag(
    id: dto.id ?? 0,
    name: dto.name ?? '',
    postCount: dto.postCount ?? 0,
    relatedTags: dto.relatedTags ?? '',
    relatedTagsUpdatedAt:
        DateTime.tryParse(dto.relatedTagsUpdatedAt ?? '') ?? DateTime.now(),
    category: intToE621TagCategory(dto.category),
    isLocked: dto.isLocked ?? false,
    createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(dto.updatedAt ?? '') ?? DateTime.now(),
  );
}
