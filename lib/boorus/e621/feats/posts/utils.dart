// Project imports:
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/string.dart';

String? booruFilterConfigToE621Tag(BooruConfigRatingFilter? filter) {
  if (filter == null) return null;

  return switch (filter) {
    BooruConfigRatingFilter.none => null,
    BooruConfigRatingFilter.hideExplicit => '-rating:e',
    BooruConfigRatingFilter.hideNSFW => 'rating:s'
  };
}

List<String> getTags(BooruConfig booruConfig, String tags) {
  final ratingTag = booruFilterConfigToE621Tag(booruConfig.ratingFilter);

  return [
    ...tags.splitByWhitespace(),
    if (ratingTag != null) ratingTag,
  ];
}
