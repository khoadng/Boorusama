import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:equatable/equatable.dart';

part 'post_favorites_event.dart';
part 'post_favorites_state.dart';

class PostFavoritesBloc extends Bloc<PostFavoritesEvent, PostFavoritesState> {
  final IPostRepository _postRepository;

  PostFavoritesBloc(this._postRepository) : super(PostFavoritesInitial());

  @override
  Stream<PostFavoritesState> mapEventToState(
    PostFavoritesEvent event,
  ) async* {
    if (event is GetFavoritePosts) {
      yield PostFavoritesLoading();
      final posts = await _postRepository.getPosts(
          "ordfav:${event.username}", event.page);
      yield PostFavoritesLoaded(posts);
    }
  }
}
