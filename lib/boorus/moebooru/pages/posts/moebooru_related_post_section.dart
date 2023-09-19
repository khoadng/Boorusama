// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/widgets/related_posts_section.dart';
import 'package:boorusama/boorus/moebooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
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
              onTap: (index) => goToMoebooruDetailsPage(
                context: context,
                posts: posts,
                initialPage: index,
              ),
            )
          : const SliverSizedBox(),
      orElse: () => const SliverSizedBox(),
    );
  }
}
