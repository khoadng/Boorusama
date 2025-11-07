// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/configs/config/types.dart';
import '../../../../client_provider.dart';
import '../types/danbooru_pool.dart';
import 'parser.dart';
import 'pool_repository_impl.dart';

final danbooruPoolRepoProvider =
    Provider.family<PoolRepository, BooruConfigAuth>((ref, config) {
      final client = ref.watch(danbooruClientProvider(config));

      return PoolRepositoryBuilder(
        fetchMany: (page, {category, description, name, order}) async {
          final data = await client.getPools(
            page: page,
            limit: 20,
            category: danbooruPoolCategoryToPoolCategory(category),
            order: danbooruPoolOrderToPoolOrder(order),
            name: name,
            description: description,
          );

          return data.map(poolDtoToDanbooruPool).nonNulls.toList();
        },
        fetchByPostId: (postId) => client
            .getPoolsFromPostId(
              postId: postId,
              limit: 20,
            )
            .then(
              (value) => value.map(poolDtoToDanbooruPool).nonNulls.toList(),
            ),
      );
    });
