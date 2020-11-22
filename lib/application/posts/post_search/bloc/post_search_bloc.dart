import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:meta/meta.dart';

part 'post_search_event.dart';
part 'post_search_state.dart';

part 'post_search_bloc.freezed.dart';

class PostSearchBloc extends Bloc<PostSearchEvent, PostSearchState> {
  final IPostRepository _postRepository;

  PostSearchBloc({
    @required IPostRepository postRepository,
  })  : _postRepository = postRepository,
        super(PostSearchState.idle());

  @override
  Stream<PostSearchState> mapEventToState(
    PostSearchEvent event,
  ) async* {
    yield* event.map(
      postSearched: (value) => _mapPostSearchedToState(value),
    );
  }

  Stream<PostSearchState> _mapPostSearchedToState(_PostSearched event) async* {
    yield const PostSearchState.idle();
    yield PostSearchState.loading(event.query, event.page);
    try {
      final posts = await _postRepository.getPosts(event.query, event.page);
      yield PostSearchState.success(posts, event.query, event.page);
    } on CannotSearchMoreThanTwoTags catch (e) {
      yield PostSearchState.error("Search Error", e.message);
    } on DatabaseTimeOut catch (e) {
      yield PostSearchState.error("Search Timeout", e.message);
    }
    yield const PostSearchState.idle();
  }
}
