// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/posts/details/parts.dart';
import 'package:boorusama/core/posts/post/post.dart';
import 'package:boorusama/router.dart';
import '../../../post/post.dart';

class DanbooruRelatedPostsSection extends ConsumerWidget {
  const DanbooruRelatedPostsSection({
    super.key,
    required this.currentPost,
    required this.posts,
  });

  final DanbooruPost currentPost;
  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverRelatedPostsSection(
      posts: posts,
      imageUrl: (item) => item.url720x720,
      onViewAll: () => goToSearchPage(
        context,
        tag: currentPost.relationshipQuery,
      ),
      onTap: (index) => goToPostDetailsPageFromPosts(
        context: context,
        posts: posts,
        initialIndex: index,
      ),
    );
  }
}
