// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/rating/types.dart';
import 'danbooru_post_version.dart';

String? resolveThumbnailWithRatingFilter({
  required DanbooruPostVersion version,
  required BooruConfigSearch? configSearch,
}) {
  final config = configSearch;
  if (config == null) return version.thumbnailUrl;

  final rating = Rating.parse(version.rating);
  final filter = config.filter;

  return switch (filter.ratingFilter) {
    BooruConfigRatingFilter.none => version.thumbnailUrl,
    BooruConfigRatingFilter.hideExplicit when rating == Rating.explicit => null,
    BooruConfigRatingFilter.hideNSFW
        when rating == Rating.explicit || rating == Rating.questionable =>
      null,
    BooruConfigRatingFilter.custom =>
      filter.granularRatingFiltersWithoutUnknown?.contains(rating) ?? false
          ? version.thumbnailUrl
          : null,
    _ => version.thumbnailUrl,
  };
}
