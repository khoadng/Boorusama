// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/utils/bloc/infinite_load_mixin.dart';

class MoebooruPostState extends Equatable
    implements InfiniteLoadState<Post, MoebooruPostState> {
  const MoebooruPostState({
    required this.data,
    required this.hasMore,
    required this.loading,
    required this.page,
    required this.refreshing,
  });

  factory MoebooruPostState.initial() => const MoebooruPostState(
        data: [],
        hasMore: true,
        loading: false,
        page: 1,
        refreshing: false,
      );

  MoebooruPostState copyWith({
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    List<Post>? data,
  }) =>
      MoebooruPostState(
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        refreshing: refreshing ?? this.refreshing,
        loading: loading ?? this.loading,
        data: data ?? this.data,
      );

  @override
  List<Object?> get props => [data, loading, refreshing, hasMore, page];

  @override
  MoebooruPostState copyLoadState({
    required int page,
    required bool hasMore,
    required bool refreshing,
    required bool loading,
    required List<Post> data,
  }) =>
      copyWith(
        page: page,
        hasMore: hasMore,
        refreshing: refreshing,
        loading: loading,
        data: data,
      );

  @override
  final List<Post> data;

  @override
  final bool hasMore;

  @override
  final bool loading;

  @override
  final int page;

  @override
  final bool refreshing;
}

abstract class MoebooruPostEvent extends Equatable {
  const MoebooruPostEvent();
}

class MoebooruPostBlocFetched extends MoebooruPostEvent {
  const MoebooruPostBlocFetched({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class MoebooruPostBlocRefreshed extends MoebooruPostEvent {
  const MoebooruPostBlocRefreshed({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class MoebooruPostBloc extends Bloc<MoebooruPostEvent, MoebooruPostState>
    with InfiniteLoadMixin<Post, MoebooruPostState> {
  MoebooruPostBloc({
    required PostRepository postRepository,
  }) : super(MoebooruPostState.initial()) {
    on<MoebooruPostBlocRefreshed>(
      (event, emit) async {
        await refresh(
          emit: EmitConfig(stateGetter: () => state, emitter: emit),
          refresh: (page) => postRepository.getPostsFromTags(event.tag, page),
        );
      },
      transformer: restartable(),
    );

    on<MoebooruPostBlocFetched>(
      (event, emit) async {
        await fetch(
          emit: EmitConfig(stateGetter: () => state, emitter: emit),
          fetch: (page) => postRepository.getPostsFromTags(event.tag, page),
        );
      },
      transformer: droppable(),
    );
  }
}
