// Package imports:
import 'package:booru_clients/e621.dart';

// Project imports:
import '../../../core/tags/categories/tag_category.dart';
import 'types.dart';

E621Tag e621TagDtoToTag(TagDto dto) {
  return E621Tag(
    id: dto.id ?? 0,
    name: dto.name ?? '',
    postCount: dto.postCount ?? 0,
    relatedTags:
        dto.relatedTags
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

TagCategory intToE621TagCategory(int? value) => switch (value) {
  0 => e621GeneralTagCategory,
  1 => e621ArtistTagCategory,
  3 => e621CopyrightTagCategory,
  4 => e621CharacterTagCategory,
  5 => e621SpeciesTagCategory,
  6 => e621InvalidTagCategory,
  7 => e621MetaTagCagegory,
  8 => e621LoreTagCategory,
  _ => e621InvalidTagCategory,
};

TagCategory stringToE621TagCategory(String? value) => switch (value) {
  'general' => e621GeneralTagCategory,
  'artist' => e621ArtistTagCategory,
  'copyright' => e621CopyrightTagCategory,
  'character' => e621CharacterTagCategory,
  'species' => e621SpeciesTagCategory,
  'invalid' => e621InvalidTagCategory,
  'meta' => e621MetaTagCagegory,
  'lore' => e621LoreTagCategory,
  _ => e621InvalidTagCategory,
};

final e621ArtistTagCategory = TagCategory.artist().copyWith(
  id: 101,
  order: 0,
);

final e621CopyrightTagCategory = TagCategory.copyright().copyWith(
  id: 103,
  order: 1,
);

final e621CharacterTagCategory = TagCategory.character().copyWith(
  id: 104,
  order: 2,
);

const e621SpeciesTagCategory = TagCategory(
  id: 105,
  order: 4,
  name: 'species',
  originalName: 'species',
);

final e621GeneralTagCategory = TagCategory.general().copyWith(
  id: 100,
  order: 5,
);

final e621MetaTagCagegory = TagCategory.meta().copyWith(
  id: 107,
  order: 7,
);

const e621LoreTagCategory = TagCategory(
  id: 108,
  order: 8,
  name: 'lore',
  originalName: 'lore',
);

const e621InvalidTagCategory = TagCategory(
  id: 106,
  order: 9,
  name: 'invalid',
  originalName: 'invalid',
);
