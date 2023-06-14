// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

part 'pools_search_provider.dart';

final danbooruPoolRepoProvider = Provider<PoolRepository>((ref) {
  final api = ref.read(danbooruApiProvider);
  final booruConfig = ref.read(currentBooruConfigProvider);

  return PoolCacher(
    PoolRepositoryApi(api, booruConfig),
  );
});

final poolDescriptionRepoProvider = Provider<PoolDescriptionRepository>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);
  final dio = ref.watch(dioProvider(booruConfig.url));

  return PoolDescriptionCacher(
      cache: LruCacher(),
      repo: PoolDescriptionRepositoryApi(
        dio: dio,
        endpoint: booruConfig.url,
      ));
});

final danbooruPoolsProvider =
    StateNotifierProvider.autoDispose<PoolsNotifier, PagedState<PoolKey, Pool>>(
        (ref) {
  final repo = ref.watch(danbooruPoolRepoProvider);
  final category = ref.watch(danbooruSelectedPoolCategoryProvider);
  final order = ref.watch(danbooruSelectedPoolOrderProvider);
  ref.watch(currentBooruConfigProvider);

  return PoolsNotifier(
    ref: ref,
    repo: repo,
    category: category,
    order: order,
  );
});

final danbooruSelectedPoolCategoryProvider =
    StateProvider<PoolCategory>((ref) => PoolCategory.series);

final danbooruSelectedPoolOrderProvider =
    StateProvider<PoolOrder>((ref) => PoolOrder.latest);

final danbooruPoolCoversProvider =
    NotifierProvider<PoolCoversNotifier, Map<int, PoolCover?>>(
  PoolCoversNotifier.new,
);

final danbooruPoolCoverProvider =
    Provider.family<PoolCover?, PoolId>((ref, id) {
  final covers = ref.watch(danbooruPoolCoversProvider);

  return covers[id];
});

typedef PoolCover = ({
  PoolId id,
  String? url,
  double aspectRatio,
});
