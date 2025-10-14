// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import '../../../../../core/configs/config/types.dart';
import '../../../../../core/posts/rating/types.dart';
import '../../../../../core/search/queries/types.dart';

class DanbooruTagQueryComposer implements TagQueryComposer {
  DanbooruTagQueryComposer({
    required this.config,
  });

  final BooruConfigSearch config;
  late final TagQueryComposer _composer = DefaultTagQueryComposer(
    config: config,
    ratingTagsFilter: switch (config.filter.ratingFilter) {
      BooruConfigRatingFilter.none => <String>[],
      BooruConfigRatingFilter.hideNSFW => [
        'rating:g',
      ],
      BooruConfigRatingFilter.hideExplicit => [
        '-rating:e',
        '-rating:q',
      ],
      BooruConfigRatingFilter.custom =>
        config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
          () => <String>[],
          (ratings) => [
            ...ratings.map((e) => '-rating:${e.toShortString()}'),
          ],
        ),
    },
  );

  @override
  List<String> compose(List<String> tags) {
    final newTags = [
      ...tags,
      switch (config.filter.deletedItemBehavior) {
        BooruConfigDeletedItemBehavior.show => null,
        BooruConfigDeletedItemBehavior.hide => '-status:deleted',
      },
    ].nonNulls.toList();

    return _composer.compose(newTags);
  }
}
