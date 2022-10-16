// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';
import 'package:boorusama/core/infra/caching/cacher.dart';

@immutable
abstract class PoolFromPostIdEvent extends Equatable {
  const PoolFromPostIdEvent();
}

class PoolFromPostIdRequested extends PoolFromPostIdEvent {
  const PoolFromPostIdRequested({
    required this.postId,
  });
  final int postId;

  @override
  List<Object?> get props => [postId];
}

class PoolFromPostIdBloc
    extends Bloc<PoolFromPostIdEvent, AsyncLoadState<List<Pool>>> {
  PoolFromPostIdBloc({
    required PoolRepository poolRepository,
  }) : super(const AsyncLoadState.initial()) {
    on<PoolFromPostIdRequested>(
      (event, emit) async {
        await tryAsync<List<Pool>>(
          action: () => poolRepository.getPoolsByPostId(event.postId),
          onFailure: (stackTrace, error) =>
              emit(const AsyncLoadState.failure()),
          onLoading: () => emit(const AsyncLoadState.loading()),
          onSuccess: (pools) async => emit(AsyncLoadState.success(pools)),
        );
      },
      transformer: debounceRestartable(const Duration(milliseconds: 150)),
    );
  }
}

class PoolFromPostCacher implements PoolRepository {
  const PoolFromPostCacher({
    required this.cache,
    required this.poolRepository,
  });

  final Cacher<int, List<Pool>> cache;
  final PoolRepository poolRepository;

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) async {
    final pools = cache.get(postId);

    if (pools != null) return pools;

    final freshPools = await poolRepository.getPoolsByPostId(postId);
    await cache.put(postId, freshPools);

    return freshPools;
  }

  @override
  Future<List<Pool>> getPools(
    int page, {
    PoolCategory? category,
    PoolOrder? order,
    String? name,
    String? description,
  }) =>
      poolRepository.getPools(
        page,
        category: category,
        order: order,
        name: name,
        description: description,
      );
}
