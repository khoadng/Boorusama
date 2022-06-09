// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/i_post_repository.dart';
import 'package:boorusama/boorus/danbooru/presentation/features/post_detail/post_detail.dart';

class RecommendedPostCubit extends Cubit<AsyncLoadState<List<Recommended>>> {
  RecommendedPostCubit({
    required this.postRepository,
  }) : super(const AsyncLoadState.initial());
  final IPostRepository postRepository;

  void getRecommendedPosts(List<String> tags) {
    tryAsync<List<Recommended>>(
        action: () =>
            Future.wait(tags.where((tag) => tag.isNotEmpty).map((tag) async {
              final posts = await postRepository.getPosts(tag, 1,
                  limit: 10, skipFavoriteCheck: true);

              final recommended =
                  Recommended(title: tag, posts: posts.take(6).toList());

              return recommended;
            }).toList()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => emit(const AsyncLoadState.loading()),
        onSuccess: (posts) => emit(AsyncLoadState.success(posts)));
  }
}

class RecommendedArtistPostCubit extends RecommendedPostCubit {
  RecommendedArtistPostCubit({required IPostRepository postRepository})
      : super(postRepository: postRepository);
}

class RecommendedCharacterPostCubit extends RecommendedPostCubit {
  RecommendedCharacterPostCubit({required IPostRepository postRepository})
      : super(postRepository: postRepository);
}
