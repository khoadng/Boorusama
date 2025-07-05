// Package imports:
import 'package:booru_clients/anime_pictures.dart';

// Project imports:
import '../../../core/tags/autocompletes/types.dart';
import '../../../core/tags/categories/tag_category.dart';
import '../../../core/tags/tag/tag.dart';

AutocompleteData autocompleteDtoToAutocompleteData(AutocompleteDto e) =>
    AutocompleteData(
      label: e.t?.toLowerCase() ?? '???',
      value: e.t?.toLowerCase() ?? '???',
      antecedent: e.t2?.toLowerCase(),
      category: animePicturesTagTypeToTagCategory(e.c).name,
    );

Tag tagDtoToTag(TagDto e) => Tag(
      name: e.tag ?? '???',
      category: animePicturesTagTypeToTagCategory(e.type),
      postCount: e.num ?? 0,
    );

final _reference = TagCategory.general().copyWith(
  id: 100,
  originalName: 'reference',
  displayName: 'Reference',
  order: 6,
);

final _copyrightProduct = TagCategory.copyright().copyWith(
  id: 101,
  originalName: 'copyright_product',
  displayName: 'Copyright (Product)',
  order: 0,
);

final _copyrightGame = TagCategory.copyright().copyWith(
  id: 102,
  originalName: 'copyright_game',
  displayName: 'Game Copyright',
  order: 1,
);

final _copyrightOther = TagCategory.copyright().copyWith(
  id: 103,
  originalName: 'copyright_other',
  displayName: 'Other Copyright',
  order: 2,
);

final _object = TagCategory.general().copyWith(
  id: 104,
  originalName: 'object',
  displayName: 'Object',
  order: 5,
);

final _author = TagCategory.artist().copyWith(
  id: 105,
  originalName: 'author',
  displayName: 'Author',
  order: 4,
);

final _character = TagCategory.character().copyWith(
  id: 106,
  order: 3,
);

final _unknown = TagCategory.unknown().copyWith(
  id: 107,
  order: 7,
);

TagCategory animePicturesTagTypeToTagCategory(AnimePicturesTagType? type) =>
    switch (type) {
      null => _unknown,
      AnimePicturesTagType.unknown => _unknown,
      AnimePicturesTagType.character => _character,
      AnimePicturesTagType.reference => _reference,
      AnimePicturesTagType.copyrightProduct => _copyrightProduct,
      AnimePicturesTagType.author => _author,
      AnimePicturesTagType.copyrightGame => _copyrightGame,
      AnimePicturesTagType.copyrightOther => _copyrightOther,
      AnimePicturesTagType.object => _object,
    };
