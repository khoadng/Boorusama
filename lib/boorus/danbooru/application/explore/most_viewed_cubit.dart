// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class MostViewedCubit extends Cubit<AsyncLoadState<List<Post>>> {
  MostViewedCubit({
    required this.postRepository,
    required this.blacklistedTagsRepository,
  }) : super(const AsyncLoadState.initial());

  final IPostRepository postRepository;
  final BlacklistedTagsRepository blacklistedTagsRepository;

  Future<void> getMostViewed() async {
    final blacklisted = await blacklistedTagsRepository.getBlacklistedTags();
    await tryAsync<List<Post>>(
        action: () => postRepository.getMostViewedPosts(DateTime.now()),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => const AsyncLoadState.loading(),
        onSuccess: (posts) async {
          if (posts.isEmpty) {
            posts = await postRepository.getMostViewedPosts(
              DateTime.now().subtract(const Duration(days: 1)),
            );
          }

          emit(AsyncLoadState.success(
              filter(posts, blacklisted).take(20).toList()));
        });
  }
}
