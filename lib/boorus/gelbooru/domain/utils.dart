// Project imports:
import 'package:boorusama/core/domain/boorus.dart';

String? booruFilterConfigToGelbooruTag(BooruConfigRatingFilter? filter) {
  if (filter == null) return null;

  switch (filter) {
    case BooruConfigRatingFilter.none:
      return null;
    case BooruConfigRatingFilter.hideExplicit:
      return '-rating:explicit';
    case BooruConfigRatingFilter.hideNSFW:
      return 'rating:general';
  }
}
