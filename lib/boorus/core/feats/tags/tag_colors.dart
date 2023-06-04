// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';

Color getTagColor(TagCategory category, ThemeMode themeMode) {
  final colors =
      themeMode == ThemeMode.light ? TagColors.light() : TagColors.dark();
  return switch (category) {
    TagCategory.artist => colors.artist,
    TagCategory.copyright => colors.copyright,
    TagCategory.charater => colors.character,
    TagCategory.general => colors.general,
    TagCategory.meta => colors.meta,
    TagCategory.invalid_ => colors.general
  };
}

class TagColors {
  const TagColors({
    required this.artist,
    required this.character,
    required this.copyright,
    required this.general,
    required this.meta,
  });

  factory TagColors.light() => const TagColors(
        artist: _red3,
        character: _green3,
        copyright: _purple3,
        general: _azure4,
        meta: _yellow2,
      );

  factory TagColors.dark() => const TagColors(
        artist: _red6,
        character: _green4,
        copyright: _magenta6,
        general: _blue5,
        meta: _orange3,
      );

  // light theme
  static const _red3 = Color.fromARGB(255, 255, 138, 139);
  static const _purple3 = Color.fromARGB(255, 199, 151, 255);
  static const _green3 = Color.fromARGB(255, 53, 198, 74);
  static const _azure4 = Color.fromARGB(255, 0, 155, 230);
  static const _yellow2 = Color.fromARGB(255, 234, 208, 132);

  // dark theme
  static const _red6 = Color.fromARGB(255, 192, 0, 4);
  static const _magenta6 = Color.fromARGB(255, 168, 0, 170);
  static const _green4 = Color.fromARGB(255, 0, 171, 44);
  static const _blue5 = Color.fromARGB(255, 0, 177, 248);
  static const _orange3 = Color.fromARGB(255, 253, 146, 0);

  final Color artist;
  final Color general;
  final Color character;
  final Color copyright;
  final Color meta;
}
