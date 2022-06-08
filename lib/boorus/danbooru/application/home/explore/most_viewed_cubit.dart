// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';

class MostViewedCubit extends Cubit<AsyncLoadState<List<Post>>> {
  MostViewedCubit({required this.postRepository})
      : super(const AsyncLoadState.initial());

  final IPostRepository postRepository;

  void getMostViewed() {
    tryAsync<List<Post>>(
        action: () => postRepository.getMostViewedPosts(DateTime.now()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => const AsyncLoadState.loading(),
        onSuccess: (posts) async {
          if (posts.isEmpty) {
            posts = await postRepository.getMostViewedPosts(
                DateTime.now().subtract(const Duration(days: 1)));
          }

          emit(AsyncLoadState.success(posts.take(20).toList()));
        });
  }
}
