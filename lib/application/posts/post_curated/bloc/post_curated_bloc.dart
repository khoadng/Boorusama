import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/i_post_repository.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/domain/posts/time_scale.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'post_curated_event.dart';
part 'post_curated_state.dart';

part 'post_curated_bloc.freezed.dart';

class PostCuratedBloc extends Bloc<PostCuratedEvent, PostCuratedState> {
  final IPostRepository _postRepository;

  PostCuratedBloc({
    @required IPostRepository postRepository,
  })  : _postRepository = postRepository,
        super(PostCuratedState.empty());

  @override
  Stream<PostCuratedState> mapEventToState(
    PostCuratedEvent event,
  ) async* {
    yield* event.map(
      requested: (e) => _mapRequestedToState(e),
      moreRequested: (e) => _mapMoreRequestedToState(e),
    );
  }

  Stream<PostCuratedState> _mapRequestedToState(_Requested event) async* {
    yield const PostCuratedState.loading();
    final posts = await _postRepository.getCuratedPosts(
      event.date,
      event.page,
      event.scale,
    );
    yield PostCuratedState.fetched(posts: posts);
  }

  Stream<PostCuratedState> _mapMoreRequestedToState(
      _MoreRequested event) async* {
    yield const PostCuratedState.additionalLoading();
    final posts = await _postRepository.getCuratedPosts(
      event.date,
      event.page,
      event.scale,
    );
    yield PostCuratedState.additionalFetched(posts: posts);
  }
}
