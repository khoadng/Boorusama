// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../core/tags/tag/colors.dart';
import 'parser.dart';

class E621TagColorGenerator implements TagColorGenerator {
  const E621TagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    final tagCategory = stringToE621TagCategory(options.tagType);

    if (tagCategory == e621InvalidTagCategory) {
      return options.colors.customColors['invalid'];
    } else if (tagCategory == e621SpeciesTagCategory) {
      return options.colors.customColors['species'];
    } else if (tagCategory == e621LoreTagCategory) {
      return options.colors.customColors['lore'];
    } else if (tagCategory == e621MetaTagCagegory) {
      return options.colors.meta;
    } else if (tagCategory == e621ArtistTagCategory) {
      return options.colors.artist;
    } else if (tagCategory == e621CopyrightTagCategory) {
      return options.colors.copyright;
    } else if (tagCategory == e621CharacterTagCategory) {
      return options.colors.character;
    } else if (tagCategory == e621GeneralTagCategory) {
      return options.colors.general;
    } else {
      return options.colors.customColors[tagCategory.name] ??
          options.colors.general;
    }
  }

  @override
  TagColors generateColors(TagColorsOptions options) {
    return const TagColors(
      general: Color(0xffb4c7d8),
      artist: Color(0xfff2ad04),
      copyright: Color(0xffd60ad8),
      character: Color(0xff05a903),
      meta: Color(0xfffefffe),
      customColors: {
        'species': Color(0xffed5d1f),
        'invalid': Color(0xfffe3c3d),
        'lore': Color(0xff218923),
      },
    );
  }
}
