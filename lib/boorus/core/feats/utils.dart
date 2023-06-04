// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/feats/user_level_colors.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
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
