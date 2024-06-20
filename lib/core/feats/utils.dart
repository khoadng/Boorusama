// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/users/users.dart';
import 'package:boorusama/core/autocompletes/autocompletes.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/users/users.dart';

Color? generateAutocompleteTagColor(
  WidgetRef ref,
  BuildContext context,
  AutocompleteData tag,
) {
  if (tag.hasCategory) {
    return ref.getTagColor(
      context,
      tag.category!,
    );
  } else if (tag.hasUserLevel) {
    return Color(getUserHexColor(stringToUserLevel(tag.level!)));
  }

  return null;
}

extension ImageQualityX on ImageQuality {
  bool get isHighres => switch (this) {
        ImageQuality.high => true,
        ImageQuality.highest => true,
        _ => false
      };
}

// convert a BooruConfig and an orignal tag list to List<String>
List<String> getTags(
  BooruConfig booruConfig,
  List<String> tags, {
  List<String>? Function(List<String> tags)? granularRatingQueries,
}) {
  final deletedStatusTag = booruConfigDeletedBehaviorToTag(
    booruConfig.deletedItemBehavior,
  );

  final data = [
    ...tags,
    if (deletedStatusTag != null) deletedStatusTag,
  ];

  return granularRatingQueries != null
      ? granularRatingQueries(data) ?? []
      : data;
}

String? booruConfigDeletedBehaviorToTag(
  BooruConfigDeletedItemBehavior? behavior,
) {
  if (behavior == null) return null;

  return switch (behavior) {
    BooruConfigDeletedItemBehavior.show => null,
    BooruConfigDeletedItemBehavior.hide => '-status:deleted'
  };
}
