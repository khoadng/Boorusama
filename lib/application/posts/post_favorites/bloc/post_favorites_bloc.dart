import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/accounts/i_favorite_post_repository.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:equatable/equatable.dart';

part 'post_favorites_event.dart';
part 'post_favorites_state.dart';

class PostFavoritesBloc extends Bloc<PostFavoritesEvent, PostFavoritesState> {
  final IPostRepository _postRepository;
  final IFavoritePostRepository _favoritePostRepository;

  PostFavoritesBloc(this._postRepository, this._favoritePostRepository)
      : super(PostFavoritesInitial());

  @override
  Stream<PostFavoritesState> mapEventToState(
    PostFavoritesEvent event,
  ) async* {
    if (event is GetFavoritePosts) {
      yield PostFavoritesLoading();
      final posts = await _postRepository.getPosts(
          "ordfav:${event.username}", event.page);
      yield PostFavoritesLoaded(posts);
    } else if (event is AddToFavorites) {
      await _favoritePostRepository.addToFavorites(event.postId);
      yield AddPostToFavoritesCompleted();
    } else if (event is RemoveFromFavorites) {
      await _favoritePostRepository.removeFromFavorites(event.postId);
      yield RemovePostToFavoritesCompleted();
    } else {
      throw Exception("Unknown event");
    }
  }
}
