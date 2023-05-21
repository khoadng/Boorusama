// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/pools/pools_notifier.dart';
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/pool/pool_cacher.dart';
import 'package:boorusama/boorus/danbooru/infra/repositories/repositories.dart';
import 'package:boorusama/core/application/boorus.dart';
import 'package:boorusama/core/infra/caching/lru_cacher.dart';
import 'package:boorusama/core/provider.dart';

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
    StateNotifierProvider<PoolsNotifier, PagedState<PoolKey, Pool>>((ref) {
  final repo = ref.read(danbooruPoolRepoProvider);
  final category = ref.watch(danbooruSelectedPoolCategoryProvider);
  final order = ref.watch(danbooruSelectedPoolOrderProvider);

  return PoolsNotifier(
    repo: repo,
    category: category,
    order: order,
  );
});

final danbooruSelectedPoolCategoryProvider = StateProvider<PoolCategory>((ref) {
  return PoolCategory.series;
});

final danbooruSelectedPoolOrderProvider = StateProvider<PoolOrder>((ref) {
  return PoolOrder.latest;
});
