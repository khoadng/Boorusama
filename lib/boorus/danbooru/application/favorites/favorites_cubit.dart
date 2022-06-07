// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class FavoritesCubit extends Cubit<AsyncLoadState<List<Post>>> {
  FavoritesCubit({
    required this.postRepository,
  }) : super(AsyncLoadState.initial());

  final IPostRepository postRepository;

  void getUserFavoritePosts(String username) {
    TryAsync<List<Post>>(
      action: () => postRepository.getPosts("ordfav:${username}", 1, limit: 10),
      onLoading: () => emit(AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
      onSuccess: (posts) => emit(AsyncLoadState.success(posts)),
    );
  }
}
