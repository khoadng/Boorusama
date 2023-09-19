enum TagCategory {
  general,
  artist,
  copyright,
  character,
  meta,
}

String tagCategoryToString(TagCategory category) => switch (category) {
      TagCategory.general => 'general',
      TagCategory.artist => 'artist',
      TagCategory.character => 'character',
      TagCategory.meta => 'meta',
      TagCategory.copyright => 'copyright'
    };

int tagCategoryToInt(TagCategory category) => switch (category) {
      TagCategory.general => 0,
      TagCategory.artist => 1,
      TagCategory.character => 3,
      TagCategory.meta => 4,
      TagCategory.copyright => 5
    };
