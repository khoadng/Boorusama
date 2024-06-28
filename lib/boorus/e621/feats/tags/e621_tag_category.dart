// Project imports:
import 'package:boorusama/core/tags/tags.dart';

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

const e621ArtistTagCategory = TagCategory(
  id: 1,
  order: 0,
  name: 'artist',
);

const e621CopyrightTagCategory = TagCategory(
  id: 3,
  order: 1,
  name: 'copyright',
);

const e621CharacterTagCategory = TagCategory(
  id: 4,
  order: 2,
  name: 'character',
);

const e621SpeciesTagCategory = TagCategory(
  id: 5,
  order: 4,
  name: 'species',
);

const e621GeneralTagCategory = TagCategory(
  id: 0,
  order: 5,
  name: 'general',
);

const e621MetaTagCagegory = TagCategory(
  id: 7,
  order: 7,
  name: 'meta',
);

const e621LoreTagCategory = TagCategory(
  id: 8,
  order: 8,
  name: 'lore',
);

const e621InvalidTagCategory = TagCategory(
  id: 6,
  order: 9,
  name: 'invalid',
);
