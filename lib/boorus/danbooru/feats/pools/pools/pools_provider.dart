// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/providers.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/foundation/caching/lru_cacher.dart';

final danbooruPoolRepoProvider = Provider<PoolRepository>((ref) {
  return PoolCacher(
    PoolRepositoryApi(
      ref.watch(danbooruApiProvider),
    ),
  );
});

final poolDescriptionRepoProvider = Provider<PoolDescriptionRepository>((ref) {
  final booruConfig = ref.watch(currentBooruConfigProvider);

  return PoolDescriptionCacher(
      cache: LruCacher(),
      repo: PoolDescriptionRepositoryApi(
        dio: ref.watch(dioProvider(booruConfig.url)),
        endpoint: booruConfig.url,
      ));
});

final danbooruPoolsProvider =
    StateNotifierProvider.autoDispose<PoolsNotifier, PagedState<PoolKey, Pool>>(
        (ref) {
  ref.watch(currentBooruConfigProvider);

  return PoolsNotifier(
    ref: ref,
    repo: ref.watch(danbooruPoolRepoProvider),
    category: ref.watch(danbooruSelectedPoolCategoryProvider),
    order: ref.watch(danbooruSelectedPoolOrderProvider),
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
