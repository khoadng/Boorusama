// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

final trendingTagsProvider =
    AsyncNotifierProvider<TrendingTagNotifier, List<Search>>(
  TrendingTagNotifier.new,
);

final shouldFetchTrendingProvider = Provider<bool>((ref) {
  final config = ref.watch(currentBooruConfigProvider);
  final booruType = intToBooruType(config.booruId);

  return booruType == BooruType.danbooru || booruType == BooruType.safebooru;
});

class TrendingTagNotifier extends AsyncNotifier<List<Search>> {
  @override
  FutureOr<List<Search>> build() {
    ref.listen(
      shouldFetchTrendingProvider,
      (previous, next) {
        if (previous != next && next) {
          ref.invalidateSelf();
        }
      },
    );

    return fetch();
  }

  PopularSearchRepository get popularSearchRepository =>
      ref.read(popularSearchProvider);

  Future<List<Search>> fetch() async {
    final excludedTags = ref.read(tagInfoProvider).r18Tags;
    var searches =
        await popularSearchRepository.getSearchByDate(DateTime.now());
    if (searches.isEmpty) {
      searches = await popularSearchRepository.getSearchByDate(
        DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    final filtered =
        searches.where((s) => !excludedTags.contains(s.keyword)).toList();

    return filtered;
  }
}
