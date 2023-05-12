// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/danbooru_provider.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';

final danbooruPostDetailsChildrenProvider = NotifierProvider.autoDispose
    .family<PostDetailsChildrenNotifier, List<DanbooruPost>, int>(
  PostDetailsChildrenNotifier.new,
  dependencies: [
    danbooruPostRepoProvider,
  ],
);

class PostDetailsChildrenNotifier
    extends AutoDisposeFamilyNotifier<List<DanbooruPost>, int>
    with DanbooruPostRepositoryMixin {
  @override
  DanbooruPostRepository get postRepository =>
      ref.read(danbooruPostRepoProvider);

  @override
  List<DanbooruPost> build(int arg) {
    return [];
  }

  Future<void> load(DanbooruPost post) async {
    if (post.hasParentOrChildren) {
      if (post.hasParent) {
        _loadParentChildPosts(
          'parent:${post.parentId}',
        );
      } else {
        _loadParentChildPosts(
          'parent:${post.id}',
        );
      }
    }
  }

  Future<void> _loadParentChildPosts(String tag) async {
    final posts = await getPostsOrEmpty(tag, 1);

    state = posts;
  }
}
