// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';
import 'package:riverpod_infinite_scroll/riverpod_infinite_scroll.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/feats/boorus/providers.dart';

part 'pools_search_provider.dart';

final danbooruPoolRepoProvider = Provider<PoolRepository>((ref) {
  final client = ref.watch(danbooruClientProvider);

  Pool poolDtoToPool(danbooru.PoolDto dto) => Pool(
        id: dto.id!,
        postIds: dto.postIds!,
        category: switch (dto.category) {
          'collection' => PoolCategory.collection,
          'series' => PoolCategory.series,
          _ => PoolCategory.unknown
        },
        description: dto.description!,
        postCount: dto.postCount!,
        name: dto.name!,
        createdAt: dto.createdAt!,
        updatedAt: dto.updatedAt!,
      );

  return PoolRepositoryBuilder(
    fetchMany: (page, {category, description, name, order}) async {
      final data = await client.getPools(
        page: page,
        limit: 20,
        category: switch (category) {
          PoolCategory.collection => danbooru.PoolCategory.collection,
          PoolCategory.series => danbooru.PoolCategory.series,
          PoolCategory.unknown => null,
          null => null,
        },
        order: switch (order) {
          PoolOrder.newest => danbooru.PoolOrder.createdAt,
          PoolOrder.latest => danbooru.PoolOrder.updatedAt,
          PoolOrder.postCount => danbooru.PoolOrder.postCount,
          PoolOrder.name => danbooru.PoolOrder.name,
          null => null,
        },
        name: name,
        description: description,
      );

      return data.map(poolDtoToPool).toList();
    },
    fetchByPostId: (postId) => client
        .getPoolsFromPostId(
          postId: postId,
          limit: 20,
        )
        .then((value) => value.map(poolDtoToPool).toList()),
  );
});

final poolDescriptionRepoProvider = Provider<PoolDescriptionRepository>((ref) {
  return PoolDescriptionRepoBuilder(
    fetchDescription: (poolId) async {
      final html = await ref
          .watch(danbooruClientProvider)
          .getPoolDescriptionHtml(poolId);

      final document = parse(html);

      return document.getElementById('description')?.outerHtml ?? '';
    },
  );
});

typedef PoolDescriptionState = ({
  String description,
  String descriptionEndpointRefUrl,
});

final poolDescriptionProvider = FutureProvider.autoDispose
    .family<PoolDescriptionState, PoolId>((ref, poolId) async {
  final repo = ref.watch(poolDescriptionRepoProvider);
  final desc = await repo.getDescription(poolId);

  return (
    description: desc,
    descriptionEndpointRefUrl: ref.watch(currentBooruConfigProvider).url,
  );
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
