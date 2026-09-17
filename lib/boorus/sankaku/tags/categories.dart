// Project imports:
import '../../../core/tags/categories/types.dart';

enum SankakuTagType {
  general(0),
  artist(1),
  studio(2),
  copyright(3),
  character(4),
  genre(5),
  medium(8),
  meta(9);

  const SankakuTagType(this.apiId);

  static SankakuTagType? fromApiId(int? id) => switch (id) {
    0 => general,
    1 => artist,
    2 => studio,
    3 => copyright,
    4 => character,
    5 => genre,
    8 => medium,
    9 => meta,
    _ => null,
  };

  final int apiId;
}

const kSankakuStudioTagCategory = TagCategory(
  id: 2,
  name: 'studio',
  order: 1,
);

const kSankakuGenreTagCategory = TagCategory(
  id: 5,
  name: 'genre',
  order: 5,
);

const kSankakuMediumTagCategory = TagCategory(
  id: 8,
  name: 'medium',
  order: 6,
);

const kSankakuMetaTagCategory = TagCategory(
  id: 9,
  name: 'meta',
  order: 7,
);

TagCategory sankakuTagCategoryFromApiId(int? id) {
  return switch (SankakuTagType.fromApiId(id)) {
    SankakuTagType.general => TagCategory.general(),
    SankakuTagType.artist => TagCategory.artist(),
    SankakuTagType.studio => kSankakuStudioTagCategory,
    SankakuTagType.copyright => TagCategory.copyright(),
    SankakuTagType.character => TagCategory.character(),
    SankakuTagType.genre => kSankakuGenreTagCategory,
    SankakuTagType.medium => kSankakuMediumTagCategory,
    SankakuTagType.meta => kSankakuMetaTagCategory,
    null => TagCategory(
      id: id ?? -1,
      name: id == null ? 'unknown' : 'sankaku_unknown_$id',
      displayName: id == null ? 'Unknown' : 'Other ($id)',
      order: 999,
    ),
  };
}
