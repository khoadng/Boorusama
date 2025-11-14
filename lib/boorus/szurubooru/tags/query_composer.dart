// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/rating/types.dart';
import '../../../core/search/queries/types.dart';

class SzurubooruTagQueryComposer implements TagQueryComposer {
  SzurubooruTagQueryComposer({
    required this.config,
  });

  final BooruConfigSearch config;
  late final TagQueryComposer _composer = DefaultTagQueryComposer(
    config: config,
    ratingTagsFilter: switch (config.filter.ratingFilter) {
      BooruConfigRatingFilter.none => [],
      BooruConfigRatingFilter.hideNSFW => [
        '-rating:sketchy,unsafe',
      ],
      BooruConfigRatingFilter.hideExplicit => [
        '-rating:unsafe',
      ],
      BooruConfigRatingFilter.custom =>
        TagQueryComposer.extractTagsFromGranularFilter(
          config.filter.granularRatingFilters,
          (rating) => '-rating:${ratingToSzurubooruRatingString(rating)}',
        ),
    },
  );

  @override
  List<String> compose(List<String> tags) {
    return _composer.compose(tags);
  }
}

String ratingToSzurubooruRatingString(Rating rating) => switch (rating) {
  Rating.unknown => 'sketchy',
  Rating.explicit => 'unsafe',
  Rating.questionable => 'sketchy',
  Rating.sensitive => 'sketchy',
  Rating.general => 'safe',
};
