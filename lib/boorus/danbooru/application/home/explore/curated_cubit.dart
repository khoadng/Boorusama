// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class CuratedCubit extends Cubit<AsyncLoadState<List<Post>>> {
  CuratedCubit({required this.postRepository})
      : super(const AsyncLoadState.initial());

  final IPostRepository postRepository;

  void getCurated() {
    tryAsync<List<Post>>(
        action: () =>
            postRepository.getCuratedPosts(DateTime.now(), 1, TimeScale.day),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => const AsyncLoadState.loading(),
        onSuccess: (posts) async {
          if (posts.isEmpty) {
            posts = await postRepository.getCuratedPosts(
                DateTime.now().subtract(const Duration(days: 1)),
                1,
                TimeScale.day);
          }

          emit(AsyncLoadState.success(posts.take(20).toList()));
        });
  }
}
