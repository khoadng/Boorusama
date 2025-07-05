// Package imports:
import 'package:booru_clients/danbooru.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../core/blacklists/providers.dart';
import '../../../../core/configs/config.dart';
import '../../../../core/tags/configs/providers.dart';
import '../../../../core/tags/tag/providers.dart';
import '../../../../core/tags/tag/tag.dart';
import '../../../../foundation/riverpod/riverpod.dart';
import '../../client_provider.dart';
import 'types.dart';

final popularSearchProvider =
    Provider.family<PopularSearchRepository, BooruConfigAuth>(
  (ref, config) {
    return PopularSearchRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);

final trendingTagsProvider = FutureProvider.autoDispose
    .family<List<Tag>, BooruConfigFilter>((ref, arg) async {
  ref.invalidateSelfAfter(const Duration(minutes: 15));

  final popularSearchRepository = ref.watch(popularSearchProvider(arg.auth));

  final bl = await ref.watch(blacklistTagsProvider(arg).future);
  final excludedTags = {
    ...ref.watch(tagInfoProvider).r18Tags,
    ...bl,
  };

  var searches = await popularSearchRepository.getSearchByDate(DateTime.now());
  if (searches.isEmpty) {
    searches = await popularSearchRepository.getSearchByDate(
      DateTime.now().subtract(const Duration(days: 1)),
    );
  }

  final filtered =
      searches.where((s) => !excludedTags.contains(s.keyword)).toList();

  final tagResolver = ref.watch(tagResolverProvider(arg.auth));

  final tags =
      await tagResolver.resolveRawTags(filtered.map((e) => e.keyword).toList());

  // Sort tags by hit count (descending order)
  // Create a map from keyword to hit count for efficient lookup
  final hitCountMap = {
    for (final search in filtered) search.keyword: search.hitCount,
  };

  // Sort tags by hit count in descending order
  tags.sort((a, b) {
    final hitCountA = hitCountMap[a.name] ?? 0;
    final hitCountB = hitCountMap[b.name] ?? 0;
    return hitCountB.compareTo(hitCountA);
  });

  return tags;
});

class PopularSearchRepositoryApi implements PopularSearchRepository {
  PopularSearchRepositoryApi({
    required this.client,
  });

  final DanbooruClient client;

  @override
  Future<List<Search>> getSearchByDate(DateTime date) async {
    try {
      final result = await client.getPopularSearchByDate(date: date).then(
            (value) => value
                .map(
                  (e) => Search(
                    hitCount: e.hitCount,
                    keyword: e.keyword,
                  ),
                )
                .toList(),
          );
      return result;
    } on DioException catch (e, stackTrace) {
      if (e.type == DioExceptionType.cancel) {
        // Cancel token triggered, skip this request
        return [];
      } else {
        Error.throwWithStackTrace(
          Exception('Failed to get search stats for $date'),
          stackTrace,
        );
      }
    }
  }
}
