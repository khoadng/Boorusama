// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

String? booruFilterConfigToDanbooruTag(BooruConfigRatingFilter? filter) {
  if (filter == null) return null;

  switch (filter) {
    case BooruConfigRatingFilter.none:
      return null;
    case BooruConfigRatingFilter.hideExplicit:
      return '-rating:e';
    case BooruConfigRatingFilter.hideNSFW:
      return 'rating:g';
  }
}

String? booruConfigDeletedBehaviorToDanbooruTag(
  BooruConfigDeletedItemBehavior? behavior,
) {
  if (behavior == null) return null;

  switch (behavior) {
    case BooruConfigDeletedItemBehavior.show:
      return null;
    case BooruConfigDeletedItemBehavior.hide:
      return '-status:deleted';
  }
}
