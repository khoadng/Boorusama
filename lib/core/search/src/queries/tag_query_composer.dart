// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:foundation/foundation.dart';

// Project imports:
import 'package:boorusama/core/configs/config.dart';
import 'package:boorusama/core/posts/rating/rating.dart';

abstract class TagQueryComposer {
  List<String> compose(List<String> tags);
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
    final alwaysIncludeTags =
        _parseAlwaysIncludeTags(config.filter.alwaysIncludeTags);

    final data = {
      ...alwaysIncludeTags,
      ...tags,
      if (ratingTagsFilter != null) ...ratingTagsFilter!,
    };

    return data.toList();
  }

  List<String> _parseAlwaysIncludeTags(String? alwaysIncludeTags) {
    if (alwaysIncludeTags == null || alwaysIncludeTags.isEmpty) {
      return [];
    }

    try {
      final json = jsonDecode(alwaysIncludeTags);

      if (json is List) {
        final tags = [for (final tag in json) tag as String];
        return tags;
      }

      return [];
    } catch (e) {
      return [];
    }
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
        config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
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
        BooruConfigDeletedItemBehavior.hide => '-status:deleted'
      },
    ].nonNulls.toList();

    return _composer.compose(newTags);
  }
}

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

class GelbooruV2TagQueryComposer implements TagQueryComposer {
  GelbooruV2TagQueryComposer({
    required this.config,
  });

  final BooruConfigSearch config;
  late final TagQueryComposer _composer = DefaultTagQueryComposer(
    config: config,
    ratingTagsFilter: switch (config.filter.ratingFilter) {
      BooruConfigRatingFilter.none => <String>[],
      BooruConfigRatingFilter.hideNSFW => [
          'rating:safe',
        ],
      BooruConfigRatingFilter.hideExplicit => [
          '-rating:explicit',
        ],
      BooruConfigRatingFilter.custom =>
        config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
              () => <String>[],
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
        config.filter.granularRatingFiltersWithoutUnknown.toOption().fold(
              () => [],
              (ratings) => [
                ...ratings
                    .map((e) => '-rating:${ratingToSzurubooruRatingString(e)}'),
              ],
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
