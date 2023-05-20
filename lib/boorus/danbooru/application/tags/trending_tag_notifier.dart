// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/tags.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/provider.dart';
import 'tags_provider.dart';

final trendingTagsProvider =
    AsyncNotifierProvider<TrendingTagNotifier, List<Search>>(
  TrendingTagNotifier.new,
  dependencies: [
    popularSearchProvider,
    tagInfoProvider,
    currentBooruConfigProvider,
  ],
);

class TrendingTagNotifier extends AsyncNotifier<List<Search>> {
  @override
  FutureOr<List<Search>> build() {
    ref.watch(currentBooruConfigProvider);

    return [];
  }

  PopularSearchRepository get popularSearchRepository =>
      ref.read(popularSearchProvider);

  Future<void> fetch() async {
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

    state = AsyncData(filtered);
  }
}
