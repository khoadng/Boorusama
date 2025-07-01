// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/posts/details/details.dart';
import '../../../../../core/posts/details/routes.dart';
import '../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../core/posts/post/post.dart';
import '../../../../../core/search/search/routes.dart';
import '../../posts.dart';
import '../providers/providers.dart';

class MoebooruRelatedPostsSection extends ConsumerWidget {
  const MoebooruRelatedPostsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<MoebooruPost>(context);
    final params = (ref.watchConfigSearch, post);

    final postsAsync = ref.watch(moebooruPostDetailsChildrenProvider(params));

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
                initialThumbnailUrl: posts[index].sampleImageUrl,
              ),
            )
          : const SliverSizedBox(),
      orElse: () => const SliverSizedBox(),
    );
  }
}
