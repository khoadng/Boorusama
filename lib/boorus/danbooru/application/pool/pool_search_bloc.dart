// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/pools/pools.dart';
import 'package:boorusama/common/bloc_stream_transformer.dart';

class PoolSearchState extends Equatable {
  const PoolSearchState({
    required this.query,
    required this.pools,
    required this.isDone,
  });

  factory PoolSearchState.initial() => const PoolSearchState(
        query: '',
        pools: [],
        isDone: false,
      );

  final String query;
  final List<Pool> pools;
  final bool isDone;

  PoolSearchState copyWith({
    String? query,
    List<Pool>? pools,
    bool? isDone,
  }) =>
      PoolSearchState(
        query: query ?? this.query,
        pools: pools ?? this.pools,
        isDone: isDone ?? this.isDone,
      );

  @override
  List<Object> get props => [query, pools, isDone];
}

abstract class PoolSearchEvent extends Equatable {
  const PoolSearchEvent();
}

class PoolSearched extends PoolSearchEvent {
  const PoolSearched(this.query);

  final String query;

  @override
  List<Object> get props => [query];
}

class PoolSearchResumed extends PoolSearchEvent {
  const PoolSearchResumed();

  @override
  List<Object> get props => [];
}

class PoolSearchCleared extends PoolSearchEvent {
  const PoolSearchCleared();

  @override
  List<Object> get props => [];
}

class PoolSearchItemSelect extends PoolSearchEvent {
  const PoolSearchItemSelect(this.poolName);

  final String poolName;

  @override
  List<Object> get props => [poolName];
}

class PoolSearchBloc extends Bloc<PoolSearchEvent, PoolSearchState> {
  PoolSearchBloc({
    required PoolRepository poolRepository,
  }) : super(PoolSearchState.initial()) {
    on<PoolSearched>(
      (event, emit) async {
        await tryAsync<List<Pool>>(
          action: () => poolRepository.getPools(1, name: event.query),
          onSuccess: (pools) async {
            emit(state.copyWith(
              query: event.query,
              pools: pools,
              isDone: false,
            ));
          },
        );
      },
      transformer: debounceRestartable(
        const Duration(milliseconds: 80),
      ),
    );

    on<PoolSearchItemSelect>((event, emit) {
      emit(state.copyWith(
        query: event.poolName,
        pools: [],
        isDone: true,
      ));
    });

    on<PoolSearchCleared>((event, emit) {
      emit(state.copyWith(
        query: '',
        pools: [],
        isDone: false,
      ));
    });

    on<PoolSearchResumed>((event, emit) {
      emit(state.copyWith(
        isDone: false,
      ));
    });
  }
}
