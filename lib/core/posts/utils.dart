// convert a BooruConfig and an orignal tag list to List<String>

// Project imports:
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/functional.dart';

List<String> getTags(
  BooruConfig booruConfig,
  List<String> tags, {
  List<String>? Function(List<String> tags)? granularRatingQueries,
}) {
  final deletedStatusTag = booruConfigDeletedBehaviorToTag(
    booruConfig.deletedItemBehavior,
  );

  final data = [
    ...tags,
    if (deletedStatusTag != null) deletedStatusTag,
  ];

  return granularRatingQueries != null
      ? granularRatingQueries(data) ?? []
      : data;
}

String? booruConfigDeletedBehaviorToTag(
  BooruConfigDeletedItemBehavior? behavior,
) {
  if (behavior == null) return null;

  return switch (behavior) {
    BooruConfigDeletedItemBehavior.show => null,
    BooruConfigDeletedItemBehavior.hide => '-status:deleted'
  };
}

abstract class TagQueryComposer {
  List<String> compose(List<String> tags);
}

class DefaultTagQueryComposer implements TagQueryComposer {
  DefaultTagQueryComposer({
    required this.config,
    this.ratingTagsFilter,
  });

  final BooruConfig config;
  final List<String>? ratingTagsFilter;

  @override
  List<String> compose(List<String> tags) {
    final data = {
      ...tags,
      if (ratingTagsFilter != null) ...ratingTagsFilter!,
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

  final BooruConfig config;
  late final TagQueryComposer _composer = DefaultTagQueryComposer(
    config: config,
    ratingTagsFilter: switch (config.ratingFilter) {
      BooruConfigRatingFilter.none => [],
      BooruConfigRatingFilter.hideNSFW => [
          'rating:safe',
        ],
      BooruConfigRatingFilter.hideExplicit => [
          '-rating:explicit',
        ],
      BooruConfigRatingFilter.custom =>
        config.granularRatingFiltersWithoutUnknown.toOption().fold(
              () => [],
              (ratings) => [
                ...ratings.map((e) => '-rating:${e.toFullString(
                      legacy: true,
                    )}'),
              ],
            ),
    },
  );

  @override
  List<String> compose(List<String> tags) {
    return _composer.compose(tags);
  }
}

class DanbooruTagQueryComposer implements TagQueryComposer {
  DanbooruTagQueryComposer({
    required this.config,
  });

  final BooruConfig config;

  @override
  List<String> compose(List<String> tags) {
    final deletedStatusTag = booruConfigDeletedBehaviorToTag(
      config.deletedItemBehavior,
    );

    final ratingTag = switch (config.ratingFilter) {
      BooruConfigRatingFilter.none => <String>[],
      BooruConfigRatingFilter.hideNSFW => [
          'rating:g',
        ],
      BooruConfigRatingFilter.hideExplicit => [
          '-rating:e',
          '-rating:q',
        ],
      BooruConfigRatingFilter.custom =>
        config.granularRatingFiltersWithoutUnknown.toOption().fold(
              () => <String>[],
              (ratings) => [
                ...ratings.map((e) => '-rating:${e.toShortString()}'),
              ],
            ),
    };

    final data = {
      ...tags,
      if (deletedStatusTag != null) deletedStatusTag,
      ...ratingTag,
    };

    return data.toList();
  }
}

class GelbooruTagQueryComposer implements TagQueryComposer {
  GelbooruTagQueryComposer({
    required this.config,
  });

  final BooruConfig config;

  @override
  List<String> compose(List<String> tags) {
    final ratingTag = switch (config.ratingFilter) {
      BooruConfigRatingFilter.none => <String>[],
      BooruConfigRatingFilter.hideNSFW => [
          'rating:general',
        ],
      BooruConfigRatingFilter.hideExplicit => [
          '-rating:explicit',
        ],
      BooruConfigRatingFilter.custom =>
        config.granularRatingFiltersWithoutUnknown.toOption().fold(
              () => <String>[],
              (ratings) => [
                ...ratings.map((e) => '-rating:${e.toFullString()}'),
              ],
            ),
    };

    final data = {
      ...tags,
      ...ratingTag,
    };

    return data.toList();
  }
}

class GelbooruV2TagQueryComposer implements TagQueryComposer {
  GelbooruV2TagQueryComposer({
    required this.config,
  });

  final BooruConfig config;

  @override
  List<String> compose(List<String> tags) {
    final ratingTag = switch (config.ratingFilter) {
      BooruConfigRatingFilter.none => <String>[],
      BooruConfigRatingFilter.hideNSFW => [
          'rating:safe',
        ],
      BooruConfigRatingFilter.hideExplicit => [
          '-rating:explicit',
        ],
      BooruConfigRatingFilter.custom =>
        config.granularRatingFiltersWithoutUnknown.toOption().fold(
              () => <String>[],
              (ratings) => [
                ...ratings.map((e) => '-rating:${e.toFullString(
                      legacy: true,
                    )}'),
              ],
            ),
    };

    final data = {
      ...tags,
      ...ratingTag,
    };

    return data.toList();
  }
}
