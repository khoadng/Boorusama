// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';

class PoolFromPostIdCubit extends Cubit<AsyncLoadState<List<Pool>>> {
  PoolFromPostIdCubit({
    required this.poolRepository,
  }) : super(const AsyncLoadState.initial());

  final PoolRepository poolRepository;

  void getPools(int postId) {
    tryAsync<List<Pool>>(
      action: () => poolRepository.getPoolsByPostId(postId),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onSuccess: (pools) => emit(AsyncLoadState.success(pools)),
    );
  }
}
