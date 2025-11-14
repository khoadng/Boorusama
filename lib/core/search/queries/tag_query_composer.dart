// Project imports:
import '../../configs/config/types.dart';
import '../../posts/rating/types.dart';

abstract class TagQueryComposer {
  List<String> compose(List<String> tags);

  static List<String> extractTagsFromGranularFilter(
    GranularRatingFilter? filter,
    String Function(Rating rating) formatter,
  ) => switch (filter?.withoutUnknown()) {
    null => [],
    final f when f.ratings.isNotEmpty => f.ratings.map(formatter).toList(),
    _ => [],
  };
}

class DefaultTagQueryComposer implements TagQueryComposer {
  DefaultTagQueryComposer({
    required this.config,
    this.ratingTagsFilter,
  });

  final BooruConfigSearch config;
  final List<String>? ratingTagsFilter;

  @override
  List<String> compose(List<String> tags) {
    final alwaysIncludeTags = config.filter.alwaysIncludeTags?.tags ?? [];

    final data = {
      ...alwaysIncludeTags,
      ...tags,
      ...?ratingTagsFilter,
    };

    return data.toList();
  }
}

class EmptyTagQueryComposer implements TagQueryComposer {
  @override
  List<String> compose(List<String> tags) {
    return tags;
  }
}

class LegacyTagQueryComposer implements TagQueryComposer {
  LegacyTagQueryComposer({
    required this.config,
  });

  final BooruConfigSearch config;
  late final TagQueryComposer _composer = DefaultTagQueryComposer(
    config: config,
    ratingTagsFilter: switch (config.filter.ratingFilter) {
      BooruConfigRatingFilter.none => [],
      BooruConfigRatingFilter.hideNSFW => [
        'rating:safe',
      ],
      BooruConfigRatingFilter.hideExplicit => [
        '-rating:explicit',
      ],
      BooruConfigRatingFilter.custom =>
        TagQueryComposer.extractTagsFromGranularFilter(
          config.filter.granularRatingFilters,
          (rating) =>
              '-rating:${rating.toFullString(
                legacy: true,
              )}',
        ),
    },
  );

  @override
  List<String> compose(List<String> tags) {
    return _composer.compose(tags);
  }
}
