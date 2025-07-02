// Package imports:
import 'package:booru_clients/e621.dart';

// Project imports:
import 'category.dart';
import 'types.dart';

E621Tag e621TagDtoToTag(TagDto dto) {
  return E621Tag(
    id: dto.id ?? 0,
    name: dto.name ?? '',
    postCount: dto.postCount ?? 0,
    relatedTags: dto.relatedTags
            ?.map(
              (e) => E621RelatedTag(
                tag: e.tag,
                score: e.score,
              ),
            )
            .toList() ??
        [],
    relatedTagsUpdatedAt:
        DateTime.tryParse(dto.relatedTagsUpdatedAt ?? '') ?? DateTime.now(),
    category: intToE621TagCategory(dto.category),
    isLocked: dto.isLocked ?? false,
    createdAt: DateTime.tryParse(dto.createdAt ?? '') ?? DateTime.now(),
    updatedAt: DateTime.tryParse(dto.updatedAt ?? '') ?? DateTime.now(),
  );
}
