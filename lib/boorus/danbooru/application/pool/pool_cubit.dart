// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiver/iterables.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/core/utils.dart';

@immutable
class PoolItem {
  const PoolItem({
    this.coverUrl,
    required this.poolName,
    required this.lastUpdated,
    required this.category,
    required this.postCount,
    required this.poolDescription,
    required this.postIds,
  });

  final String? coverUrl;
  final String poolName;
  final String lastUpdated;
  final PoolCategory category;
  final int postCount;
  final String poolDescription;
  final List<int> postIds;
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
                coverUrl: _(pair).item1.id == 0
                    ? null
                    : _(pair).item1.normalImageUri.toString(),
                poolName: _(pair).item2.name.value.removeUnderscoreWithSpace(),
                lastUpdated: dateTimeToString(_(pair).item2.updatedAt),
                category: _(pair).item2.category,
                postCount: _(pair).item2.postCount.value,
                poolDescription: _(pair).item2.description.value,
                postIds: _(pair).item2.postIds.reversed.take(20).toList()),
        ];

        emit(AsyncLoadState.success(poolItems));
      },
    );
  }
}

String dateTimeToString(DateTime time) {
  final now = DateTime.now();
  final diff = now.difference(time);
  final ago = now.subtract(diff);

  return timeago.format(ago);
}

Tuple2<Post, Pool> _(List<Object> pair) =>
    Tuple2(pair[0] as Post, pair[1] as Pool);
