// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../core/configs/config/types.dart';
import '../../../core/posts/rating/rating.dart';
import '../../../core/search/queries/query.dart';

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
        config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
          () => <String>[],
          (ratings) => [
            ...ratings.map((e) => '-rating:${e.toFullString()}'),
          ],
        ),
    },
  );

  @override
  List<String> compose(List<String> tags) {
    return _composer.compose(tags);
  }
}
