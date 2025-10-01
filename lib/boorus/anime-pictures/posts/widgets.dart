// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../core/configs/config/providers.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details_parts/widgets.dart';
import 'parser.dart';
import 'providers.dart';
import 'types.dart';

class AnimePicturesRelatedPostsSection extends ConsumerWidget {
  const AnimePicturesRelatedPostsSection({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final posts = PostDetails.of<AnimePicturesPost>(context).posts;
    final post = InheritedPost.of<AnimePicturesPost>(context);
    final configAuth = ref.watchConfigAuth;
    final configViewer = ref.watchConfigViewer;
    final params = (configAuth, post.id);
    final mediaUrlResolver = ref.watch(
      animePicturesMediaUrlResolverProvider(configAuth),
    );

    return ref
        .watch(postDetailsProvider(params))
        .when(
          data: (details) => details.tied != null && details.tied!.isNotEmpty
              ? SliverRelatedPostsSection(
                  posts: details.tied!.map(dtoToAnimePicturesPost).toList(),
                  imageUrl: (post) =>
                      mediaUrlResolver.resolveMediaUrl(post, configViewer),
                  onTap: (index) => goToPostDetailsPageFromPosts(
                    ref: ref,
                    posts: posts,
                    initialIndex: index,
                    initialThumbnailUrl: mediaUrlResolver.resolveMediaUrl(
                      posts[index],
                      configViewer,
                    ),
                  ),
                )
              : const SliverSizedBox.shrink(),
          error: (e, _) => const SliverSizedBox.shrink(),
          loading: () => const SliverSizedBox.shrink(),
        );
  }
}
