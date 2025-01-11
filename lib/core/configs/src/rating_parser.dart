// Package imports:
import 'package:collection/collection.dart';

// Project imports:
import '../../posts/rating/rating.dart';

Set<Rating>? parseGranularRatingFilters(String? granularRatingFilterString) {
  if (granularRatingFilterString == null) return null;

  return granularRatingFilterString
      .split('|')
      .map((e) => mapStringToRating(e))
      .toSet();
}

String? granularRatingFilterToString(
  Set<Rating>? granularRatingFilters, {
  bool? sort,
}) {
  if (granularRatingFilters == null) return null;

  final shouldSort = sort ?? false;

  final ratingStrings = granularRatingFilters.map((e) => e.toShortString());

  final effectiveRatingStrings =
      shouldSort ? ratingStrings.sorted() : ratingStrings;

  return effectiveRatingStrings.join('|');
}
