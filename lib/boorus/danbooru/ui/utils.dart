// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/users.dart';
import 'package:boorusama/boorus/danbooru/ui/features/users/users.dart';
import 'package:boorusama/core/application/theme.dart';
import 'package:boorusama/core/domain/autocompletes.dart';
import 'package:boorusama/core/domain/tags.dart';
import 'package:boorusama/core/ui/tags/tags.dart';

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
