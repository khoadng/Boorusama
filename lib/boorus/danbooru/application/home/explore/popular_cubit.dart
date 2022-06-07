// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/post.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PopularCubit extends Cubit<AsyncLoadState<List<Post>>> {
  PopularCubit({required this.postRepository})
      : super(AsyncLoadState.initial());

  final IPostRepository postRepository;

  void getPopular() {
    TryAsync<List<Post>>(
        action: () =>
            postRepository.getPopularPosts(DateTime.now(), 1, TimeScale.day),
        onFailure: (stackTrace, error) => emit(AsyncLoadState.failure()),
        onLoading: () => AsyncLoadState.loading(),
        onSuccess: (posts) async {
          if (posts.isEmpty) {
            posts = await postRepository.getPopularPosts(
                DateTime.now().subtract(Duration(days: 1)), 1, TimeScale.day);
          }

          emit(AsyncLoadState.success(posts.take(20).toList()));
        });
  }
}
