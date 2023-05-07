// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/ui/users/users.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/ui/tags.dart';

Color? generateDanbooruAutocompleteTagColor(
  AutocompleteData tag,
  ThemeMode theme,
) {
  if (tag.hasCategory) {
    return getTagColor(
      stringToTagCategory(tag.category!),
      theme,
    );
  } else if (tag.hasUserLevel) {
    return Color(getUserHexColor(stringToUserLevel(tag.level!)));
  }

  return null;
}

String mapImageQualityToThumbnailUrl(DanbooruPost post, ImageQuality quality) {
  switch (quality) {
    case ImageQuality.low:
      return post.url360x360;
    case ImageQuality.high:
      return post.url720x720;
    case ImageQuality.original:
      return post.urlSample;
    case ImageQuality.automatic:
      return post.url720x720;
  }
}
