// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/users/users.dart';
import 'package:boorusama/common/bloc/bloc.dart';

class PostFavoriteState extends Equatable
    implements InfiniteLoadState<User, PostFavoriteState> {
  const PostFavoriteState({
    required this.favoriters,
    required this.page,
    required this.hasMore,
    required this.refreshing,
    required this.loading,
    this.error,
  });

  factory PostFavoriteState.initial() => const PostFavoriteState(
        favoriters: [],
        page: 1,
        hasMore: true,
        refreshing: false,
        loading: false,
      );

  final List<User> favoriters;
  @override
  List<User> get data => favoriters;
  @override
  final int page;
  @override
  final bool hasMore;
  @override
  final bool refreshing;
  @override
  final bool loading;
  final String? error;

  PostFavoriteState copyWith({
    List<User>? favoriters,
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    String? error,
  }) =>
      PostFavoriteState(
        favoriters: favoriters ?? this.favoriters,
        page: page ?? this.page,
        hasMore: hasMore ?? this.hasMore,
        refreshing: refreshing ?? this.refreshing,
        loading: loading ?? this.loading,
        error: error ?? this.error,
      );

  @override
  List<Object?> get props => [
        favoriters,
        page,
        hasMore,
        refreshing,
        loading,
        error,
      ];

  @override
  PostFavoriteState copyLoadState({
    required int page,
    required bool hasMore,
    required bool refreshing,
    required bool loading,
    required List<User> data,
  }) =>
      copyWith(
        favoriters: [...data],
        page: page,
        refreshing: refreshing,
        loading: loading,
        hasMore: hasMore,
      );
}

abstract class PostFavoriteEvent extends Equatable {
  const PostFavoriteEvent();
}

class PostFavoriteFetched extends PostFavoriteEvent {
  const PostFavoriteFetched({
    required this.postId,
    this.refresh = false,
  });

  final int postId;
  final bool refresh;

  @override
  List<Object?> get props => [
        postId,
        refresh,
      ];
}

class PostFavoriteBloc extends Bloc<PostFavoriteEvent, PostFavoriteState>
    with InfiniteLoadMixin<User, PostFavoriteState> {
  PostFavoriteBloc({
    required FavoritePostRepository favoritePostRepository,
    required UserRepository userRepository,
    List<User>? initialData,
  }) : super(PostFavoriteState.initial()) {
    on<PostFavoriteFetched>(
      (event, emit) async {
        if (loading || refreshing) return;

        if (event.refresh) {
          await refresh(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            refresh: (page) => favoritePostRepository
                .getFavorites(event.postId, page)
                .then(createUserWith(userRepository)),
            onError: (error, stackTrace) =>
                emit(state.copyWith(error: 'Something went wrong')),
          );
        } else {
          await fetch(
            emit: EmitConfig(
              stateGetter: () => state,
              emitter: emit,
            ),
            fetch: (page) => favoritePostRepository
                .getFavorites(event.postId, page)
                .then(createUserWith(userRepository)),
            onError: (error, stackTrace) =>
                emit(state.copyWith(error: 'Something went wrong')),
          );
        }
      },
    );

    data = initialData ?? [];
  }
}
