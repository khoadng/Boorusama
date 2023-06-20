// Flutter imports:
import 'package:flutter/material.dart';

enum E621TagCategory {
  general,
  artist,
  invalid_,
  copyright,
  charater,
  species,
  invalid,
  meta,
  lore,
}

E621TagCategory intToE621TagCategory(int? value) => switch (value) {
      0 => E621TagCategory.general,
      1 => E621TagCategory.artist,
      3 => E621TagCategory.copyright,
      4 => E621TagCategory.charater,
      5 => E621TagCategory.species,
      6 => E621TagCategory.invalid,
      7 => E621TagCategory.meta,
      8 => E621TagCategory.lore,
      _ => E621TagCategory.general
    };

extension E621TagCategoryX on E621TagCategory {
  Color toColor() => switch (this) {
        E621TagCategory.general => const Color(0xffb4c7d8),
        E621TagCategory.artist => const Color(0xfff2ad04),
        E621TagCategory.invalid_ => Colors.grey,
        E621TagCategory.copyright => const Color(0xffd60ad8),
        E621TagCategory.charater => const Color(0xff05a903),
        E621TagCategory.species => const Color(0xffed5d1f),
        E621TagCategory.invalid => const Color(0xfffe3c3d),
        E621TagCategory.meta => const Color(0xfffefffe),
        E621TagCategory.lore => const Color(0xff218923),
      };

  Color toOnBackgroundColor() => switch (this) {
        E621TagCategory.general => Colors.black,
        E621TagCategory.artist => Colors.white,
        E621TagCategory.invalid_ => Colors.grey,
        E621TagCategory.copyright => Colors.white,
        E621TagCategory.charater => Colors.white,
        E621TagCategory.species => Colors.white,
        E621TagCategory.invalid => Colors.white,
        E621TagCategory.meta => const Color(0xff000000),
        E621TagCategory.lore => const Color(0xffffffff),
      };
}
