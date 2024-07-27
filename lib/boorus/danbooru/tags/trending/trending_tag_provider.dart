// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/configs.dart';
import '../tags.dart';

final trendingTagsProvider = AsyncNotifierProvider.autoDispose
    .family<TrendingTagNotifier, List<Search>, BooruConfig>(
  TrendingTagNotifier.new,
);

final popularSearchProvider =
    Provider.family<PopularSearchRepository, BooruConfig>(
  (ref, config) {
    return PopularSearchRepositoryApi(
      client: ref.watch(danbooruClientProvider(config)),
    );
  },
);
