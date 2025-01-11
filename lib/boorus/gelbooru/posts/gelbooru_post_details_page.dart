// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../core/posts/details/details.dart';
import '../../../core/posts/details/routes.dart';
import '../../../core/posts/details_parts/widgets.dart';
import '../../../core/search/search/routes.dart';
import '../../../core/tags/tag/providers.dart';
import '../../../core/tags/tag/tag.dart';
import '../artists/artists.dart';
import 'posts.dart';

class GelbooruTagListSection extends ConsumerStatefulWidget {
  const GelbooruTagListSection({
    super.key,
  });

  @override
  ConsumerState<GelbooruTagListSection> createState() =>
      _GelbooruTagListSectionState();
}

class _GelbooruTagListSectionState
    extends ConsumerState<GelbooruTagListSection> {
  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return SliverToBoxAdapter(
      child: TagsTile(
        tags: ref.watch(tagGroupProvider(post)).maybeWhen(
              orElse: () => const [],
              data: (data) => data.tags,
            ),
        post: post,
        onTagTap: (tag) => goToSearchPage(context, tag: tag.rawName),
      ),
    );
  }
}

class GelbooruCharacterListSection extends ConsumerWidget {
  const GelbooruCharacterListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<GelbooruPost>(context);

    return ref.watch(tagGroupProvider(post)).maybeWhen(
          data: (data) => data.characterTags.isNotEmpty
              ? SliverCharacterPostList(
                  tags: data.characterTags,
                )
              : const SliverSizedBox.shrink(),
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}

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

    return MultiSliver(
      children: ref.watch(tagGroupProvider(post)).maybeWhen(
            data: (data) => data.artistTags.isNotEmpty
                ? data.artistTags
                    .map(
                      (tag) => SliverArtistPostList(
                        tag: tag,
                        child: ref
                            .watch(gelbooruArtistPostsProvider(tag))
                            .maybeWhen(
                              data: (data) => SliverPreviewPostGrid(
                                posts: data,
                                onTap: (postIdx) =>
                                    goToPostDetailsPageFromPosts(
                                  context: context,
                                  posts: data,
                                  initialIndex: postIdx,
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
