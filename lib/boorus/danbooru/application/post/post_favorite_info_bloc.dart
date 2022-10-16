// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user.dart';
import 'package:boorusama/boorus/danbooru/domain/users/user_repository.dart';

class PostFavoriteInfoState extends Equatable {
  const PostFavoriteInfoState({
    required this.favoriters,
    required this.page,
    required this.hasMore,
    required this.refreshing,
    required this.loading,
    this.error,
  });

  factory PostFavoriteInfoState.initial() => const PostFavoriteInfoState(
        favoriters: [],
        page: 1,
        hasMore: false,
        refreshing: false,
        loading: false,
      );

  final List<User> favoriters;
  final int page;
  final bool hasMore;
  final bool refreshing;
  final bool loading;
  final String? error;

  PostFavoriteInfoState copyWith({
    List<User>? favoriters,
    int? page,
    bool? hasMore,
    bool? refreshing,
    bool? loading,
    String? error,
  }) =>
      PostFavoriteInfoState(
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
}

abstract class PostFavoriteInfoEvent extends Equatable {
  const PostFavoriteInfoEvent();
}

class PostFavoriteInfoFetched extends PostFavoriteInfoEvent {
  const PostFavoriteInfoFetched({
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

class PostFavoriteInfoBloc
    extends Bloc<PostFavoriteInfoEvent, PostFavoriteInfoState> {
  PostFavoriteInfoBloc({
    required FavoritePostRepository favoritePostRepository,
    required UserRepository userRepository,
  }) : super(PostFavoriteInfoState.initial()) {
    on<PostFavoriteInfoFetched>(
      (event, emit) async {
        try {
          if (state.loading || state.refreshing) return;

          if (event.refresh) {
            emit(state.copyWith(
              refreshing: true,
              page: 1,
            ));

            final favs = await favoritePostRepository.getFavorites(
                event.postId, state.page);

            final users = await userRepository
                .getUsersByIdStringComma(favs.map((e) => e.userId).join(','));
            emit(state.copyWith(
              refreshing: false,
              favoriters: users,
              hasMore: true,
            ));
          } else {
            if (!state.hasMore) return;
            final page = state.page + 1;
            emit(state.copyWith(loading: true));

            final favs =
                await favoritePostRepository.getFavorites(event.postId, page);

            // Prevent fetching more if next page is empty
            if (favs.isEmpty) {
              emit(state.copyWith(
                loading: false,
                hasMore: false,
              ));
            } else {
              final users = await userRepository
                  .getUsersByIdStringComma(favs.map((e) => e.userId).join(','));
              emit(state.copyWith(
                loading: false,
                favoriters: [...state.favoriters, ...users],
                hasMore: true,
              ));
            }

            emit(state.copyWith(page: page));
          }
        } catch (e) {
          emit(state.copyWith(error: 'Something went wrong'));
        }
      },
    );
  }
}
