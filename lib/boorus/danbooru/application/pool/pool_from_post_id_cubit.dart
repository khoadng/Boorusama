// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pool/pool.dart';
import 'package:boorusama/boorus/danbooru/infrastructure/repositories/pool/pool_repository.dart';

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
      (event, emit) => tryAsync<List<Pool>>(
        action: () => poolRepository.getPoolsByPostId(event.postId),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onSuccess: (pools) => emit(AsyncLoadState.success(pools)),
      ),
      transformer: restartable(),
    );
  }
}
