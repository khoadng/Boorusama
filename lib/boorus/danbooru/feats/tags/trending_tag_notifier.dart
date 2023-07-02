// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';

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

    ref
        .read(danbooruTagCategoriesProviderProvider.notifier)
        .save(filtered.map((e) => e.keyword).toList());

    return filtered;
  }
}
