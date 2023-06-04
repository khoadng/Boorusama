// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/tags/tags.dart';
import 'package:boorusama/boorus/core/ui/tags.dart';
import 'package:boorusama/boorus/core/ui/user_level_colors.dart';
import 'package:boorusama/boorus/danbooru/features/users/users.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';

Color? generateAutocompleteTagColor(
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
