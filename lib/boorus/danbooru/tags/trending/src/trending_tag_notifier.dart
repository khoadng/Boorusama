// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../core/blacklists/providers.dart';
import '../../../../../core/configs/config.dart';
import '../../../../../core/tags/categories/providers.dart';
import '../../../../../core/tags/configs/providers.dart';
import '../../../../../core/tags/tag/providers.dart';
import 'popular_search_repository.dart';
import 'search.dart';
import 'trending_tag_provider.dart';

final trendingTagsProvider = AsyncNotifierProvider.autoDispose
    .family<TrendingTagNotifier, List<Search>, BooruConfigFilter>(
  TrendingTagNotifier.new,
);

class TrendingTagNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Search>, BooruConfigFilter> {
  @override
  FutureOr<List<Search>> build(BooruConfigFilter arg) {
    return fetch();
  }

  PopularSearchRepository get popularSearchRepository =>
      ref.read(popularSearchProvider(arg.auth));

  Future<List<Search>> fetch() async {
    final bl = await ref.read(blacklistTagsProvider(arg).future);
    final excludedTags = {
      ...ref.read(tagInfoProvider).r18Tags,
      ...bl,
    };

    var searches =
        await popularSearchRepository.getSearchByDate(DateTime.now());
    if (searches.isEmpty) {
      searches = await popularSearchRepository.getSearchByDate(
        DateTime.now().subtract(const Duration(days: 1)),
      );
    }

    final filtered =
        searches.where((s) => !excludedTags.contains(s.keyword)).toList();

    final tags = await ref
        .read(tagRepoProvider(arg.auth))
        .getTagsByName(filtered.map((e) => e.keyword).toSet(), 1);

    await ref
        .read(booruTagTypeStoreProvider)
        .saveTagIfNotExist(arg.auth.booruType, tags);

    return filtered;
  }
}
