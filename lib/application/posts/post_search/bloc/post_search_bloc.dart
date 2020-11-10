import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/repositories/posts/post_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'post_search_event.dart';
part 'post_search_state.dart';

class PostSearchBloc extends Bloc<PostSearchEvent, PostSearchState> {
  final IPostRepository _postRepository;

  PostSearchBloc({
    @required IPostRepository postRepository,
  })  : _postRepository = postRepository,
        super(SearchIdle());

  @override
  Stream<PostSearchState> mapEventToState(
    PostSearchEvent event,
  ) async* {
    if (event is PostSearched) {
      String query = event.query;
      int page = event.page;

      yield SearchLoading();

      try {
        final posts = await _postRepository.getPosts(query, page);
        yield SearchSuccess(posts: posts, query: query, page: page);
      } on CannotSearchMoreThanTwoTags catch (e) {
        yield SearchError(message: e.message, error: "Search Error");
      } on DatabaseTimeOut catch (e) {
        yield SearchError(message: e.message, error: "Search Timeout");
      }

      yield SearchIdle();
    }
  }
}
