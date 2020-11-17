import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'post_popular_event.dart';
part 'post_popular_state.dart';

part 'post_popular_bloc.freezed.dart';

class PostPopularBloc extends Bloc<PostPopularEvent, PostPopularState> {
  final IPostRepository _postRepository;

  PostPopularBloc({
    @required IPostRepository postRepository,
  })  : _postRepository = postRepository,
        super(PostPopularState.empty());

  @override
  Stream<PostPopularState> mapEventToState(
    PostPopularEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
      moreRequested: (e) => _mapMoreRequestedToState(e),
    );
  }

  Stream<PostPopularState> _mapRequestedToState(_Requested event) async* {
    yield const PostPopularState.loading();
    final posts = await _postRepository.getPopularPosts(
      event.date,
      event.page,
      event.scale,
    );
    yield PostPopularState.fetched(posts: posts);
  }

  Stream<PostPopularState> _mapMoreRequestedToState(
      _MoreRequested event) async* {
    yield const PostPopularState.additionalLoading();
    final posts = await _postRepository.getPopularPosts(
      event.date,
      event.page,
      event.scale,
    );
    yield PostPopularState.additionalFetched(posts: posts);
  }
}
