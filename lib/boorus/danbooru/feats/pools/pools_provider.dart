// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:html/parser.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/clients/danbooru/types/types.dart' as danbooru;
import 'package:boorusama/core/configs/configs.dart';

part 'pools_search_provider.dart';

final danbooruPoolRepoProvider =
    Provider.family<PoolRepository, BooruConfig>((ref, config) {
  final client = ref.watch(danbooruClientProvider(config));

  DanbooruPool poolDtoToDanbooruPool(danbooru.PoolDto dto) => DanbooruPool(
        id: dto.id!,
        postIds: dto.postIds!,
        category: switch (dto.category) {
          'collection' => DanbooruPoolCategory.collection,
          'series' => DanbooruPoolCategory.series,
          _ => DanbooruPoolCategory.unknown
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
          DanbooruPoolCategory.collection => danbooru.PoolCategory.collection,
          DanbooruPoolCategory.series => danbooru.PoolCategory.series,
          DanbooruPoolCategory.unknown => null,
          null => null,
        },
        order: switch (order) {
          DanbooruPoolOrder.newest => danbooru.PoolOrder.createdAt,
          DanbooruPoolOrder.latest => danbooru.PoolOrder.updatedAt,
          DanbooruPoolOrder.postCount => danbooru.PoolOrder.postCount,
          DanbooruPoolOrder.name => danbooru.PoolOrder.name,
          null => null,
        },
        name: name,
        description: description,
      );

      return data.map(poolDtoToDanbooruPool).toList();
    },
    fetchByPostId: (postId) => client
        .getPoolsFromPostId(
          postId: postId,
          limit: 20,
        )
        .then((value) => value.map(poolDtoToDanbooruPool).toList()),
  );
});

final poolSuggestionsProvider = FutureProvider.autoDispose
    .family<List<DanbooruPool>, String>((ref, query) async {
  if (query.isEmpty) return [];

  final config = ref.watchConfig;
  final repo = ref.watch(danbooruPoolRepoProvider(config));

  return repo.getPools(
    1,
    name: query,
    order: DanbooruPoolOrder.postCount,
  );
});

final poolDescriptionRepoProvider =
    Provider.family<PoolDescriptionRepository, BooruConfig>((ref, config) {
  return PoolDescriptionRepoBuilder(
    fetchDescription: (poolId) async {
      final html = await ref
          .watch(danbooruClientProvider(config))
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
  final config = ref.watchConfig;
  final repo = ref.watch(poolDescriptionRepoProvider(config));
  final desc = await repo.getDescription(poolId);

  return (
    description: desc,
    descriptionEndpointRefUrl: config.url,
  );
});

final danbooruSelectedPoolCategoryProvider =
    StateProvider<DanbooruPoolCategory>((ref) => DanbooruPoolCategory.series);

final danbooruSelectedPoolOrderProvider =
    StateProvider<DanbooruPoolOrder>((ref) => DanbooruPoolOrder.latest);

final danbooruPoolCoversProvider = NotifierProvider.family<PoolCoversNotifier,
    Map<int, PoolCover?>, BooruConfig>(
  PoolCoversNotifier.new,
);

final danbooruPoolCoverProvider =
    Provider.autoDispose.family<PoolCover?, PoolId>((ref, id) {
  final config = ref.watchConfig;
  final covers = ref.watch(danbooruPoolCoversProvider(config));

  return covers[id];
});
