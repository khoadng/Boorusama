import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:boorusama/application/posts/post_search/bloc/post_search_bloc.dart';
import 'package:boorusama/domain/posts/post.dart';
import 'package:equatable/equatable.dart';
import 'package:meta/meta.dart';

part 'post_list_event.dart';
part 'post_list_state.dart';

class PostListBloc extends Bloc<PostListEvent, PostListState> {
  final PostSearchBloc _postSearchBloc;
  StreamSubscription _postSearchBlocSubscription;

  PostListBloc({@required PostSearchBloc postSearchBloc})
      : _postSearchBloc = postSearchBloc,
        super(PostListEmpty()) {
    _postSearchBlocSubscription = _postSearchBloc.listen((state) {
      state.maybeWhen(
          success: (posts, query, page) {
            if (page == 1) {
              add(ListLoadRequested(posts));
            } else {
              add(MorePostLoaded(posts));
            }
          },
          orElse: () {});
    });
  }

  @override
  Stream<PostListState> mapEventToState(
    PostListEvent event,
  ) async* {
    if (event is ListLoadRequested) {
      yield PostListLoaded(event.posts);
    } else if (event is MorePostLoaded) {
      yield AddtionalPostListLoaded(event.posts);
    }
  }

  @override
  Future<void> close() {
    _postSearchBlocSubscription.cancel();
    return super.close();
  }
}
