// Project imports:
import 'e621_tag.dart';
import 'e621_tag_category.dart';
import 'e621_tag_dto.dart';

E621Tag e621TagDtoToTag(E621TagDto dto) {
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
