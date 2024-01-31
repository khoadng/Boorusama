// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/tags/booru_tag_type_store.dart';
import 'package:boorusama/core/feats/tags/tags.dart';

class TrendingTagNotifier
    extends AutoDisposeFamilyAsyncNotifier<List<Search>, BooruConfig> {
  @override
  FutureOr<List<Search>> build(BooruConfig arg) async {
    final r18Tags = ref.watch(tagInfoProvider).r18Tags;
    final blacklistTags =
        await ref.watch(danbooruBlacklistedTagsProvider(arg).future);
    final globalBlacklistTags = ref.watch(globalBlacklistedTagsProvider);

    return fetch(
      excludedTags: {
        ...r18Tags,
        if (blacklistTags != null) ...blacklistTags,
        ...globalBlacklistTags.map((e) => e.name),
      },
    );
  }

  PopularSearchRepository get popularSearchRepository =>
      ref.read(popularSearchProvider(arg));

  Future<List<Search>> fetch({
    required Set<String> excludedTags,
  }) async {
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
        .read(tagRepoProvider(arg))
        .getTagsByName(filtered.map((e) => e.keyword).toList(), 1);

    await ref
        .read(booruTagTypeStoreProvider)
        .saveTagIfNotExist(arg.booruType, tags);

    return filtered;
  }
}
