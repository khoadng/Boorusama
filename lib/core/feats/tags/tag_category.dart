enum TagCategory {
  general,
  artist,
  invalid_,
  copyright,
  charater,
  meta,
}

extension TagCategoryX on TagCategory {
  String stringify() => switch (this) {
        TagCategory.general => '0',
        TagCategory.artist => '1',
        TagCategory.invalid_ => '2',
        TagCategory.copyright => '3',
        TagCategory.charater => '4',
        TagCategory.meta => '5'
      };
}

TagCategory intToTagCategory(int? value) => switch (value) {
      0 => TagCategory.general,
      1 => TagCategory.artist,
      3 => TagCategory.copyright,
      4 => TagCategory.charater,
      5 => TagCategory.meta,
      _ => TagCategory.general
    };

TagCategory stringToTagCategory(String value) => switch (value) {
      '0' || 'tag' => TagCategory.general,
      '1' || 'artist' => TagCategory.artist,
      '3' || 'copyright' => TagCategory.copyright,
      '4' || 'character' => TagCategory.charater,
      '5' || 'metadata' => TagCategory.meta,
      _ => TagCategory.general
    };
