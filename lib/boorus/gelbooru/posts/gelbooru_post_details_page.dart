// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../core/configs/ref.dart';
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/tags/tag/providers.dart';
import '../artists/artists.dart';
import 'posts.dart';

class GelbooruFileDetailsSection extends StatelessWidget {
  const GelbooruFileDetailsSection({
    super.key,
    this.initialExpanded = false,
  });

  final bool initialExpanded;

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return SliverToBoxAdapter(
      child: DefaultFileDetailsSection(
        post: post,
        initialExpanded: initialExpanded,
        uploaderName: post.uploaderName,
      ),
    );
  }
}

class GelbooruArtistPostsSection extends ConsumerWidget {
  const GelbooruArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruPost>(context);
    final auth = ref.watchConfigAuth;

    return MultiSliver(
      children: ref
          .watch(artistCharacterGroupProvider((post: post, auth: auth)))
          .maybeWhen(
            data: (data) => data.artistTags.isNotEmpty
                ? data.artistTags
                    .map(
                      (tag) => SliverArtistPostList(
                        tag: tag,
                        child: ref
                            .watch(
                              gelbooruArtistPostsProvider(
                                (
                                  ref.watchConfigFilter,
                                  ref.watchConfigSearch,
                                  tag
                                ),
                              ),
                            )
                            .maybeWhen(
                              data: (data) => SliverPreviewPostGrid(
                                posts: data,
                                onTap: (postIdx) =>
                                    goToPostDetailsPageFromPosts(
                                  context: context,
                                  posts: data,
                                  initialIndex: postIdx,
                                  initialThumbnailUrl:
                                      getGelbooruPostPreviewImageUrl(
                                    data[postIdx],
                                  ),
                                ),
                                imageUrl: getGelbooruPostPreviewImageUrl,
                              ),
                              orElse: () =>
                                  const SliverPreviewPostGridPlaceholder(),
                            ),
                      ),
                    )
                    .toList()
                : [],
            orElse: () => [],
          ),
    );
  }
}

String getGelbooruPostPreviewImageUrl(GelbooruPost post) {
  if (post.isVideo) return post.videoThumbnailUrl;

  if (post.sampleImageUrl.isNotEmpty) return post.sampleImageUrl;

  return post.thumbnailImageUrl;
}
