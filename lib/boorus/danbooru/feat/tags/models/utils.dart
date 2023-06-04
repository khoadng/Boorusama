// Project imports:
import 'package:boorusama/boorus/core/feat/boorus/boorus.dart';

String? booruFilterConfigToDanbooruTag(BooruConfigRatingFilter? filter) {
  if (filter == null) return null;

  return switch (filter) {
    BooruConfigRatingFilter.none => null,
    BooruConfigRatingFilter.hideExplicit => '-rating:e,q',
    BooruConfigRatingFilter.hideNSFW => 'rating:g'
  };
}

String? booruConfigDeletedBehaviorToDanbooruTag(
  BooruConfigDeletedItemBehavior? behavior,
) {
  if (behavior == null) return null;

  return switch (behavior) {
    BooruConfigDeletedItemBehavior.show => null,
    BooruConfigDeletedItemBehavior.hide => '-status:deleted'
  };
}
