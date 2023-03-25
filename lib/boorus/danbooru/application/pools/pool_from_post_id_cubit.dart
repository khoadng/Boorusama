// Flutter imports:
import 'package:flutter/foundation.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/pools.dart';
import 'package:boorusama/core/application/common.dart';
import 'package:boorusama/utils/bloc/bloc.dart';

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
