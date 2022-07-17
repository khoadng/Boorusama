// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class PopularCubit extends Cubit<AsyncLoadState<List<Post>>> {
  PopularCubit({
    required this.postRepository,
    required this.blacklistedTagsRepository,
  }) : super(const AsyncLoadState.initial());

  final IPostRepository postRepository;
  final BlacklistedTagsRepository blacklistedTagsRepository;

  Future<void> getPopular() async {
    final blacklisted = await blacklistedTagsRepository.getBlacklistedTags();

    await tryAsync<List<Post>>(
        action: () =>
            postRepository.getPopularPosts(DateTime.now(), 1, TimeScale.day),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => const AsyncLoadState.loading(),
        onSuccess: (posts) async {
          if (posts.isEmpty) {
            posts = await postRepository.getPopularPosts(
              DateTime.now().subtract(const Duration(days: 1)),
              1,
              TimeScale.day,
            );
          }

          emit(AsyncLoadState.success(
              filter(posts, blacklisted).take(20).toList()));
        });
  }
}
