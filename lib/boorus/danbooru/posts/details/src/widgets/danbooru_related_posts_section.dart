// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../../../../core/posts/details/routes.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/posts/post/post.dart';
import '../../../../../../core/search/search/routes.dart';
import '../../../post/post.dart';

class DanbooruRelatedPostsSection extends ConsumerWidget {
  const DanbooruRelatedPostsSection({
    required this.currentPost,
    required this.posts,
    super.key,
  });

  final DanbooruPost currentPost;
  final List<DanbooruPost> posts;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SliverRelatedPostsSection(
      posts: posts,
      imageUrl: (item) => item.url720x720,
      onViewAll: () => goToSearchPage(
        ref,
        tag: currentPost.relationshipQuery,
      ),
      onTap: (index) => goToPostDetailsPageFromPosts(
        ref: ref,
        posts: posts,
        initialIndex: index,
        initialThumbnailUrl: posts[index].url720x720,
      ),
    );
  }
}
