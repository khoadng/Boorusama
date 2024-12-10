// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../core/posts/details/details.dart';
import '../../../../core/posts/details/parts.dart';
import '../../../../core/posts/post/post.dart';
import '../../../../router.dart';
import '../../feats/posts/posts.dart';

class MoebooruRelatedPostsSection extends ConsumerWidget {
  const MoebooruRelatedPostsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);

    final postsAsync = ref.watch(moebooruPostDetailsChildrenProvider(post));

    return postsAsync.maybeWhen(
      data: (posts) => posts != null
          ? SliverRelatedPostsSection(
              posts: posts,
              imageUrl: (item) => item.sampleImageUrl,
              onViewAll: () => goToSearchPage(
                context,
                tag: post.relationshipQuery,
              ),
              onTap: (index) => goToPostDetailsPageFromPosts(
                context: context,
                posts: posts,
                initialIndex: index,
              ),
            )
          : const SliverSizedBox(),
      orElse: () => const SliverSizedBox(),
    );
  }
}
