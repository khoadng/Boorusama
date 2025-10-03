// Dart imports:
import 'dart:ui';

// Project imports:
import '../../../core/tags/tag/colors.dart';

class ZerochanTagColorGenerator implements TagColorGenerator {
  const ZerochanTagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    final colors = options.colors;

    return switch (options.tagType) {
      'mangaka' ||
      'studio' ||
      // This is from a fallback in case the tag is already searched in other boorus
      'artist' => colors.artist,
      'source' ||
      'game' ||
      'visual_novel' ||
      'series' ||
      // This is from a fallback in case the tag is already searched in other boorus
      'copyright' => colors.copyright,
      'character' => colors.character,
      'meta' => colors.meta,
      _ => colors.general,
    };
  }

  @override
  TagColors generateColors(TagColorsOptions options) {
    return TagColors.fromBrightness(options.brightness);
  }
}
