import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_favorites_event.dart';
part 'post_favorites_state.dart';

part 'post_favorites_bloc.freezed.dart';

class PostFavoritesBloc extends Bloc<PostFavoritesEvent, PostFavoritesState> {
  final IPostRepository _postRepository;
  final IFavoritePostRepository _favoritePostRepository;

  PostFavoritesBloc(this._postRepository, this._favoritePostRepository)
      : super(PostFavoritesState.initial());

  @override
  Stream<PostFavoritesState> mapEventToState(
    PostFavoritesEvent event,
  ) async* {
    yield* event.map(
      fetched: (e) => _mapFetchedToState(e),
      added: (e) => _mapAddedToState(e),
      removed: (e) => _mapRemovedToState(e),
    );
  }

  Stream<PostFavoritesState> _mapFetchedToState(_Fetched event) async* {
    yield const PostFavoritesState.loading();
    final posts =
        await _postRepository.getPosts("ordfav:${event.username}", event.page);
    yield PostFavoritesState.loaded(posts: posts);
  }

  Stream<PostFavoritesState> _mapAddedToState(_Added event) async* {
    await _favoritePostRepository.addToFavorites(event.postId);
    yield const PostFavoritesState.addCompleted();
  }

  Stream<PostFavoritesState> _mapRemovedToState(_Removed event) async* {
    await _favoritePostRepository.removeFromFavorites(event.postId);
    yield const PostFavoritesState.removeComplated();
  }
}
