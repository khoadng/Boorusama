// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';
import 'package:boorusama/core/infrastructure/caching/cacher.dart';

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
          onSuccess: (pools) => emit(AsyncLoadState.success(pools)),
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
  Future<List<Pool>> getPools() => poolRepository.getPools();

  @override
  Future<List<Pool>> getPoolsByPostId(int postId) async {
    final pools = cache.get(postId);

    if (pools != null) return pools;

    final freshPools = await poolRepository.getPoolsByPostId(postId);
    cache.put(postId, freshPools);

    return freshPools;
  }
}
