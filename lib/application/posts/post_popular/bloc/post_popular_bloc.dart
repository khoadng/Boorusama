import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'post_popular_event.dart';
part 'post_popular_state.dart';

class PostPopularBloc extends Bloc<PostPopularEvent, PostPopularState> {
  final IPostRepository _postRepository;

  PostPopularBloc({
    @required IPostRepository postRepository,
  })  : _postRepository = postRepository,
        super(PostPopularEmpty());

  @override
  Stream<PostPopularState> mapEventToState(
    PostPopularEvent event,
  ) async* {
    if (event is PostPopularRequested) {
      yield PostPopularLoading();
      final posts = await _postRepository.getPopularPosts(
        event.date,
        event.page,
        event.scale,
      );

      yield PostPopularFetched(posts: posts);
    }
    if (event is LoadMorePopularPostRequested) {
      yield AdditionalPostPopularLoading();
      final posts = await _postRepository.getPopularPosts(
        event.date,
        event.page,
        event.scale,
      );

      yield AdditionalPostPopularFetched(posts: posts);
    }
  }
}
