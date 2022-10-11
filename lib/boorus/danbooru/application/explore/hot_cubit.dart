// Package imports:
import 'package:flutter_bloc/flutter_bloc.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/blacklisted_tags/blacklisted_tags.dart';
import 'package:boorusama/boorus/danbooru/application/common.dart';
import 'package:boorusama/boorus/danbooru/application/post/common.dart';
import 'package:boorusama/boorus/danbooru/domain/posts/posts.dart';

class HotCubit extends Cubit<AsyncLoadState<List<Post>>> {
  HotCubit({
    required this.postRepository,
    required this.blacklistedTagsRepository,
  }) : super(const AsyncLoadState.initial());

  final IPostRepository postRepository;
  final BlacklistedTagsRepository blacklistedTagsRepository;

  Future<void> getHot() async {
    final blacklisted = await blacklistedTagsRepository.getBlacklistedTags();

    await tryAsync<List<Post>>(
        action: () => postRepository.getPosts('order:rank', 1),
        onFailure: (stackTrace, error) => emit(const AsyncLoadState.failure()),
        onLoading: () => const AsyncLoadState.loading(),
        onSuccess: (posts) async {
          emit(AsyncLoadState.success(
              filterRawPost(posts, blacklisted).take(20).toList()));
        });
  }
}
