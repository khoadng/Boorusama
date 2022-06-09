// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';

@immutable
class PoolItem {
  const PoolItem({
    this.coverUrl,
    required this.pool,
  });

  final String? coverUrl;
  final Pool pool;
}

class PoolCubit extends Cubit<AsyncLoadState<List<PoolItem>>> {
  PoolCubit({
    required this.poolRepository,
    required this.postRepository,
  }) : super(const AsyncLoadState.initial());

  final PoolRepository poolRepository;
  final IPostRepository postRepository;

  void getPools(PoolCategory category) {
    tryAsync<List<Pool>>(
      action: () => poolRepository.getPools(),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onSuccess: (pools) async {
        final poolFiltered = pools
            .where((element) => element.postIds.isNotEmpty)
            .where((element) => element.category == category)
            .toList();

        final poolCoverIds = poolFiltered.map((e) => e.postIds.last).toList();

        final poolCoveridsMap = {for (var e in poolCoverIds) e: Post.empty()};

        final posts = await postRepository.getPostsFromIds(poolCoverIds);

        for (var p in posts) {
          poolCoveridsMap[p.id] = p;
        }

        final poolItems = [
          for (final pair
              in zip([poolCoveridsMap.values.toList(), poolFiltered]))
            PoolItem(
              coverUrl:
                  _(pair).item1.id == 0 ? null : _(pair).item1.normalImageUrl,
              pool: _(pair).item2,
            ),
        ];

        emit(AsyncLoadState.success(poolItems));
      },
    );
  }
}

Tuple2<Post, Pool> _(List<Object> pair) =>
    Tuple2(pair[0] as Post, pair[1] as Pool);
