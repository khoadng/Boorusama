// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';
import 'package:boorusama/core/application/common.dart';

class FavoritesCubit extends Cubit<AsyncLoadState<List<Post>>> {
  FavoritesCubit({
    required this.postRepository,
  }) : super(const AsyncLoadState.initial());

  final PostRepository postRepository;

  void getUserFavoritePosts(String username) {
    tryAsync<List<Post>>(
      action: () => postRepository.getPosts('ordfav:$username', 1),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onSuccess: (posts) async => emit(AsyncLoadState.success(posts)),
    );
  }
}
