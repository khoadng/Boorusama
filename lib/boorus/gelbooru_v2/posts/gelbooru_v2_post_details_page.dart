// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/posts/post/post.dart';
import '../../../core/search/search/routes.dart';
import 'gelbooru_v2_post.dart';
import 'posts_v2_provider.dart';

class GelbooruV2FileDetailsSection extends ConsumerWidget {
  const GelbooruV2FileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class GelbooruV2RelatedPostsSection extends ConsumerWidget {
  const GelbooruV2RelatedPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruV2Post>(context);

    return post.hasParent
        ? ref
            .watch(
              gelbooruV2ChildPostsProvider(
                (ref.watchConfigFilter, ref.watchConfigSearch, post),
              ),
            )
            .maybeWhen(
              data: (data) => SliverRelatedPostsSection(
                title: 'Child posts',
                posts: data,
                imageUrl: (post) => post.sampleImageUrl,
                onViewAll: () => goToSearchPage(
                  context,
                  tag: post.relationshipQuery,
                ),
                onTap: (index) => goToPostDetailsPageFromPosts(
                  context: context,
                  posts: data,
                  initialIndex: index,
                  initialThumbnailUrl: data[index].sampleImageUrl,
                ),
              ),
              orElse: () => const SliverSizedBox.shrink(),
            )
        : const SliverSizedBox.shrink();
  }
}
