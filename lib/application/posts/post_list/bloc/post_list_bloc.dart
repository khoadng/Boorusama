import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

part 'post_list_event.dart';
part 'post_list_state.dart';

part 'post_list_bloc.freezed.dart';

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostSearchBloc _postSearchBloc;
  StreamSubscription _postSearchBlocSubscription;

  PostListBloc({@required PostSearchBloc postSearchBloc})
      : _postSearchBloc = postSearchBloc,
        super(PostListState.empty()) {
    _postSearchBlocSubscription = _postSearchBloc.listen((state) {
      state.maybeWhen(
          success: (posts, query, page) {
            if (page == 1) {
              add(PostListEvent.loaded(posts: posts));
            } else {
              add(PostListEvent.moreLoaded(posts: posts));
            }
          },
          orElse: () {});
    });
  }

  @override
  Stream<PostListState> mapEventToState(
    PostListEvent event,
  ) async* {
    yield* event.map(
      loaded: (e) => _mapLoadedToState(e),
      moreLoaded: (e) => _mapLoadedMoreToState(e),
    );
  }

  Stream<PostListState> _mapLoadedToState(_Loaded event) async* {
    yield PostListState.fetched(posts: event.posts);
  }

  Stream<PostListState> _mapLoadedMoreToState(_LoadedMore event) async* {
    yield PostListState.fetchedMore(posts: event.posts);
  }

  @override
  Future<void> close() {
    _postSearchBlocSubscription.cancel();
    return super.close();
  }
}
