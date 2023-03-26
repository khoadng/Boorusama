// Package imports:
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/utils/bloc/infinite_load_mixin.dart';

class GelbooruPostState extends Equatable
    implements InfiniteLoadState<Post, GelbooruPostState> {
  const GelbooruPostState({
    required this.data,
    required this.hasMore,
    required this.loading,
    required this.page,
    required this.refreshing,
  });

  factory GelbooruPostState.initial() => const GelbooruPostState(
        data: [],
        hasMore: true,
        loading: false,
        page: 1,
        refreshing: false,
      );

  GelbooruPostState copyWith({
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    List<Post>? data,
  }) =>
      GelbooruPostState(
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        refreshing: refreshing ?? this.refreshing,
        loading: loading ?? this.loading,
        data: data ?? this.data,
      );

  @override
  List<Object?> get props => [data, loading, refreshing, hasMore, page];

  @override
  GelbooruPostState copyLoadState({
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

abstract class GelbooruPostEvent extends Equatable {
  const GelbooruPostEvent();
}

class GelbooruPostBlocFetched extends GelbooruPostEvent {
  const GelbooruPostBlocFetched({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class GelbooruPostBlocRefreshed extends GelbooruPostEvent {
  const GelbooruPostBlocRefreshed({
    required this.tag,
  });

  final String tag;

  @override
  List<Object?> get props => [tag];
}

class GelbooruPostBloc extends Bloc<GelbooruPostEvent, GelbooruPostState>
    with InfiniteLoadMixin<Post, GelbooruPostState> {
  GelbooruPostBloc({
    required PostRepository postRepository,
  }) : super(GelbooruPostState.initial()) {
    on<GelbooruPostBlocRefreshed>(
      (event, emit) async {
        await refresh(
          emit: EmitConfig(stateGetter: () => state, emitter: emit),
          refresh: (page) => postRepository.getPostsFromTags(event.tag, page),
        );
      },
      transformer: restartable(),
    );

    on<GelbooruPostBlocFetched>(
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
