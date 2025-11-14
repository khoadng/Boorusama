// Project imports:
import '../../../../../core/configs/config/types.dart';
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
        TagQueryComposer.extractTagsFromGranularFilter(
          config.filter.granularRatingFilters,
          (rating) => '-rating:${rating.toShortString()}',
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
