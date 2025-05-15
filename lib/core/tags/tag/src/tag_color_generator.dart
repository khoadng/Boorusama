// Flutter imports:
import 'package:flutter/rendering.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import 'tag_colors.dart';

abstract class TagColorGenerator {
  Color? generateColor(
    TagColorOptions options,
  );

  TagColors generateColors(
    TagColorsOptions options,
  );
}

class DefaultTagColorGenerator implements TagColorGenerator {
  const DefaultTagColorGenerator();

  @override
  Color? generateColor(TagColorOptions options) {
    final colors = options.colors;

    return switch (options.tagType) {
      '0' || 'general' || 'tag' => colors.general,
      '1' || 'artist' || 'creator' || 'studio' => colors.artist,
      '3' || 'copyright' || 'series' => colors.copyright,
      '4' || 'character' => colors.character,
      '5' || 'meta' || 'metadata' => colors.meta,
      _ => colors.general,
    };
  }

  @override
  TagColors generateColors(TagColorsOptions options) {
    return TagColors.fromBrightness(options.brightness);
  }
}
