// Package imports:
import 'package:booru_clients/danbooru.dart' as danbooru;
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/core/configs/config.dart';
import 'danbooru_pool.dart';
import 'pool_repository.dart';

final danbooruPoolRepoProvider =
    Provider.family<PoolRepository, BooruConfigAuth>((ref, config) {
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
