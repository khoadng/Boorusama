enum E621TagCategory {
  general,
  artist,
  invalid_,
  copyright,
  character,
  species,
  invalid,
  meta,
  lore,
}

E621TagCategory intToE621TagCategory(int? value) => switch (value) {
      0 => E621TagCategory.general,
      1 => E621TagCategory.artist,
      3 => E621TagCategory.copyright,
      4 => E621TagCategory.character,
      5 => E621TagCategory.species,
      6 => E621TagCategory.invalid,
      7 => E621TagCategory.meta,
      8 => E621TagCategory.lore,
      _ => E621TagCategory.general
    };
