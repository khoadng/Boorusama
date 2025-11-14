// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/search/queries/types.dart';

class GelbooruTagQueryComposer implements TagQueryComposer {
  GelbooruTagQueryComposer({
    required this.config,
  });

  final BooruConfigSearch config;
  late final TagQueryComposer _composer = DefaultTagQueryComposer(
    config: config,
    ratingTagsFilter: switch (config.filter.ratingFilter) {
      BooruConfigRatingFilter.none => <String>[],
      BooruConfigRatingFilter.hideNSFW => [
        'rating:general',
      ],
      BooruConfigRatingFilter.hideExplicit => [
        '-rating:explicit',
      ],
      BooruConfigRatingFilter.custom =>
        TagQueryComposer.extractTagsFromGranularFilter(
          config.filter.granularRatingFilters,
          (rating) => '-rating:${rating.toFullString()}',
        ),
    },
  );

  @override
  List<String> compose(List<String> tags) {
    return _composer.compose(tags);
  }
}
