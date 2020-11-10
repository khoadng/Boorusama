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
      if (state is SearchSuccess) {
        if (state.page == 1) {
          add(ListLoadRequested(state.posts));
        } else if (state.page > 1) {
          add(MorePostLoaded(state.posts));
        }
      }
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
