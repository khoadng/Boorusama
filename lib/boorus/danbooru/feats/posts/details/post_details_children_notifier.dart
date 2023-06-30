// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';

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
    if (state.isNotEmpty) return;
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
