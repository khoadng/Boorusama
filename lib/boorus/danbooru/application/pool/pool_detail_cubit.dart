// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PoolDetailCubit extends Cubit<AsyncLoadState<List<Post>>> {
  PoolDetailCubit({
    required this.postRepository,
  }) : super(const AsyncLoadState.initial());

  final IPostRepository postRepository;

  void getPoolDetail(List<int> postIds) {
    tryAsync<List<Post>>(
      action: () => postRepository.getPostsFromIds(postIds),
      onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
      onLoading: () => emit(const AsyncLoadState.loading()),
      onSuccess: (posts) => emit(AsyncLoadState.success(posts)),
    );
  }
}
