// Project imports:
import 'package:boorusama/core/posts.dart';

Set<Rating>? parseGranularRatingFilters(String? granularRatingFilterString) {
  if (granularRatingFilterString == null) return null;

  return granularRatingFilterString
      .split('|')
      .map((e) => mapStringToRating(e))
      .toSet();
}

String? granularRatingFilterToString(Set<Rating>? granularRatingFilters) {
  if (granularRatingFilters == null) return null;

  return granularRatingFilters.map((e) => e.toShortString()).join('|');
}
