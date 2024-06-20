// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/widgets/sliver_sized_box.dart';

class MoebooruRelatedPostsSection extends ConsumerWidget {
  const MoebooruRelatedPostsSection({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final postsAsync = ref.watch(moebooruPostDetailsChildrenProvider(post));

    return postsAsync.maybeWhen(
      data: (posts) => posts != null
          ? RelatedPostsSection(
              posts: posts,
              imageUrl: (item) => item.sampleImageUrl,
              onViewAll: () => goToSearchPage(
                context,
                tag: post.relationshipQuery,
              ),
              onTap: (index) => goToPostDetailsPage(
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
