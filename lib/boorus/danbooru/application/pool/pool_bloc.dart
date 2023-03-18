// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quiver/iterables.dart';
import 'package:tuple/tuple.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/common.dart';

@immutable
class PoolState extends Equatable {
  const PoolState({
    required this.status,
    required this.pools,
    required this.page,
    required this.hasMore,
    this.exceptionMessage,
  });

  factory PoolState.initial() => const PoolState(
        status: LoadStatus.initial,
        pools: [],
        page: 1,
        hasMore: true,
      );

  final List<PoolItem> pools;
  final LoadStatus status;
  final int page;
  final bool hasMore;
  final String? exceptionMessage;

  PoolState copyWith({
    LoadStatus? status,
    List<PoolItem>? pools,
    int? page,
    bool? hasMore,
    String? exceptionMessage,
  }) =>
      PoolState(
        status: status ?? this.status,
        pools: pools ?? this.pools,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        exceptionMessage: exceptionMessage ?? this.exceptionMessage,
      );

  @override
  List<Object?> get props => [status, pools, page, hasMore, exceptionMessage];
}

@immutable
abstract class PoolEvent extends Equatable {
  const PoolEvent();
}

class PoolFetched extends PoolEvent {
  const PoolFetched({
    this.category,
    this.order,
    this.name,
    this.description,
  }) : super();

  final PoolCategory? category;
  final PoolOrder? order;
  final PoolName? name;
  final PoolDescription? description;

  @override
  List<Object?> get props => [category];
}

class PoolRefreshed extends PoolEvent {
  const PoolRefreshed({
    this.category,
    this.order,
    this.name,
    this.description,
  }) : super();

  final PoolCategory? category;
  final PoolOrder? order;
  final PoolName? name;
  final PoolDescription? description;

  @override
  List<Object?> get props => [category];
}

@immutable
class PoolItem {
  const PoolItem({
    this.coverUrl,
    required this.pool,
  });

  final String? coverUrl;
  final Pool pool;
}

class PoolBloc extends Bloc<PoolEvent, PoolState> {
  PoolBloc({
    required PoolRepository poolRepository,
    required PostRepository postRepository,
  }) : super(PoolState.initial()) {
    on<PoolRefreshed>(
      (event, emit) async {
        await tryAsync<List<Pool>>(
          action: () => poolRepository.getPools(
            1,
            category: event.category,
            order: event.order,
            name: event.name,
            description: event.description,
          ),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onLoading: () => emit(state.copyWith(status: LoadStatus.initial)),
          onSuccess: (pools) async {
            final poolItems = await poolsToPoolItems(pools, postRepository);
            emit(state.copyWith(
              pools: poolItems,
              status: LoadStatus.success,
              page: 1,
              hasMore: poolItems.isNotEmpty,
            ));
          },
        );
      },
      transformer: restartable(),
    );

    on<PoolFetched>(
      (event, emit) async {
        await tryAsync<List<Pool>>(
          action: () => poolRepository.getPools(
            state.page + 1,
            category: event.category,
            order: event.order,
            name: event.name,
            description: event.description,
          ),
          onFailure: (stackTrace, error) =>
              emit(state.copyWith(status: LoadStatus.failure)),
          onLoading: () => emit(state.copyWith(status: LoadStatus.loading)),
          onSuccess: (pools) async {
            final poolItems = await poolsToPoolItems(pools, postRepository);
            emit(state.copyWith(
              pools: [...state.pools, ...poolItems],
              status: LoadStatus.success,
              page: state.page + 1,
              hasMore: poolItems.isNotEmpty,
            ));
          },
        );
      },
      transformer: droppable(),
    );
  }

  Future<List<PoolItem>> poolsToPoolItems(
    List<Pool> pools,
    PostRepository postRepository,
  ) async {
    final poolFiltered =
        pools.where((element) => element.postIds.isNotEmpty).toList();

    final poolCoverIds = poolFiltered.map((e) => e.postIds.last).toList();

    final poolCoveridsMap = {for (var e in poolCoverIds) e: Post.empty()};

    final posts = await postRepository.getPostsFromIds(poolCoverIds);

    for (final p in posts) {
      poolCoveridsMap[p.id] = p;
    }

    return [
      for (final pair in zip([poolCoveridsMap.values.toList(), poolFiltered]))
        PoolItem(coverUrl: postToCoverUrl(_(pair).item1), pool: _(pair).item2),
    ];
  }
}

String? postToCoverUrl(Post post) {
  if (post.id == 0) return null;
  if (post.isAnimated) return post.thumbnailImageUrl;

  return post.sampleImageUrl;
}

Tuple2<Post, Pool> _(List<Object> pair) =>
    Tuple2(pair.first as Post, pair[1] as Pool);
