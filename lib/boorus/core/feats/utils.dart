// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:jiffy/jiffy.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/autocompletes/autocompletes.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/feats/user_level_colors.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/foundation/theme/theme_mode.dart';
import 'types.dart';

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

extension DateTimeX on DateTime {
  Jiffy asJiffy() => Jiffy.parseFromDateTime(this);

  DateTime subtractTimeScale(TimeScale scale) => switch (scale) {
        TimeScale.day => asJiffy().subtract(days: 1).dateTime,
        TimeScale.week => asJiffy().subtract(weeks: 1).dateTime,
        TimeScale.month => asJiffy().subtract(months: 1).dateTime
      };

  DateTime addTimeScale(TimeScale scale) => switch (scale) {
        TimeScale.day => asJiffy().add(days: 1).dateTime,
        TimeScale.week => asJiffy().add(weeks: 1).dateTime,
        TimeScale.month => asJiffy().add(months: 1).dateTime
      };
}
