// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/widgets/related_posts_section.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';

class DanbooruRelatedPostsSection extends ConsumerWidget {
  const DanbooruRelatedPostsSection({
    super.key,
    required this.post,
  });

  final DanbooruPost post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = ref.watch(danbooruPostDetailsChildrenProvider(post.id));

    return RelatedPostsSection(
      posts: posts,
      imageUrl: (item) => item.url720x720,
      onTap: (index) => goToDetailPage(
        context: context,
        posts: posts,
        initialIndex: index,
      ),
    );
  }
}
