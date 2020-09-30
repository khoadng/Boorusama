import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:boorusama/infrastructure/posts/post_repository.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'post_list_event.dart';
part 'post_list_state.dart';

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostRepository _repository;

  PostListBloc(this._repository) : super(PostListInitial());

  @override
  Stream<PostListState> mapEventToState(
    PostListEvent event,
  ) async* {
    if (event is GetPost) {
      yield PostListLoading();
      try {
        final posts = await _repository.getPosts(event.tagString, event.page);
        yield PostListLoaded(posts);
      } on Error {
        yield PostListError("Something's wrong");
      }
    }
  }
}
