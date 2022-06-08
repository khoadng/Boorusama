// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiver/iterables.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/core/utils.dart';
import 'package:tuple/tuple.dart';

@immutable
class PoolItem {
  PoolItem({
    required this.coverUrl,
    required this.poolName,
    required this.timeString,
    required this.category,
    required this.postCount,
  });

  final String coverUrl;
  final String poolName;
  final String timeString;
  final PoolCategory category;
  final int postCount;
}

class PoolCubit extends Cubit<AsyncLoadState<List<PoolItem>>> {
  PoolCubit({
    required this.poolRepository,
    required this.postRepository,
  }) : super(AsyncLoadState.initial());

  final PoolRepository poolRepository;
  final IPostRepository postRepository;

  void getPools(PoolCategory category) {
    TryAsync<List<Pool>>(
      action: () => poolRepository.getPools(),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onLoading: () => emit(AsyncLoadState.loading()),
      onSuccess: (pools) async {
        final poolItemsRaw = pools
            .where((element) => element.postIds.isNotEmpty)
            .where((element) => element.category == category)
            .map(
              (p) => Tuple4(
                p.postCoverId!,
                p.name,
                p.category,
                p.postCount,
              ),
            )
            .toList();

        final posts = await postRepository
            .getPostsFromIds(poolItemsRaw.map((e) => e.item1).toList());

        final poolItems = [
          for (final pair in zip([posts, poolItemsRaw]))
            PoolItem(
              coverUrl: _(pair).item1.previewImageUri.toString(),
              poolName: _(pair).item2.item2.value.removeUnderscoreWithSpace(),
              timeString: _(pair).item1.createdAt.toString(),
              category: _(pair).item2.item3,
              postCount: _(pair).item2.item4.value,
            ),
        ];

        emit(AsyncLoadState.success(poolItems));
      },
    );
  }
}

Tuple2<Post, Tuple4<int, PoolName, PoolCategory, PoolPostCount>> _(
        List<Object> pair) =>
    Tuple2(pair[0] as Post,
        pair[1] as Tuple4<int, PoolName, PoolCategory, PoolPostCount>);
