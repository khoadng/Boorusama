// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../../../core/artists/artists.dart';
import '../../../../../../core/posts/details/details.dart';
import '../../../../../../core/posts/details/routes.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../artists/commentaries/providers.dart';
import '../../../../comments/comment/providers.dart';
import '../../../pools/pool/widgets.dart';
import '../../../post/post.dart';
import '../danbooru_post_details_page.dart';
import '../providers.dart';
import 'danbooru_file_details.dart';
import 'danbooru_related_posts_section.dart';
import 'danbooru_tags_tile.dart';

class DanbooruPoolTiles extends ConsumerWidget {
  const DanbooruPoolTiles({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverToBoxAdapter(
      child: ref.watch(danbooruPostDetailsPoolsProvider(post.id)).maybeWhen(
            data: (pools) => PoolTiles(pools: pools),
            orElse: () => const SizedBox.shrink(),
          ),
    );
  }
}

class DanbooruInformationSection extends ConsumerWidget {
  const DanbooruInformationSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverToBoxAdapter(
      child: SimpleInformationSection(
        post: post,
        showSource: true,
      ),
    );
  }
}

class DanbooruArtistInfoSection extends ConsumerWidget {
  const DanbooruArtistInfoSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary:
            ref.watch(danbooruArtistCommentaryProvider(post.id)).maybeWhen(
                  data: (commentary) => commentary,
                  orElse: () => const ArtistCommentary.empty(),
                ),
        artistTags: post.artistTags,
        source: post.source,
      ),
    );
  }
}

class DanbooruTagsSection extends ConsumerWidget {
  const DanbooruTagsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverToBoxAdapter(
      child: DanbooruTagsTile(post: post),
    );
  }
}

class DanbooruStatsSection extends ConsumerWidget {
  const DanbooruStatsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverToBoxAdapter(
      child: DanbooruPostStatsTile(
        post: post,
        commentCount:
            ref.watch(danbooruCommentCountProvider(post.id)).maybeWhen(
                  data: (count) => count,
                  orElse: () => null,
                ),
      ),
    );
  }
}

class DanbooruFileDetailsSection extends ConsumerWidget {
  const DanbooruFileDetailsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverToBoxAdapter(
      child: DanbooruFileDetails(post: post),
    );
  }
}

class DanbooruArtistPostsSection extends ConsumerWidget {
  const DanbooruArtistPostsSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return MultiSliver(
      children: post.artistTags.isNotEmpty
          ? post.artistTags
              .map(
                (tag) => SliverArtistPostList(
                  tag: tag,
                  child: ref
                      .watch(danbooruPostDetailsArtistProvider(tag))
                      .maybeWhen(
                        data: (data) => SliverPreviewPostGrid(
                          posts: data,
                          onTap: (postIdx) => goToPostDetailsPageFromPosts(
                            context: context,
                            posts: data,
                            initialIndex: postIdx,
                          ),
                          imageUrl: (item) => item.url360x360,
                        ),
                        orElse: () => const SliverPreviewPostGridPlaceholder(),
                      ),
                ),
              )
              .toList()
          : [],
    );
  }
}

class DanbooruRelatedPostsSection2 extends ConsumerWidget {
  const DanbooruRelatedPostsSection2({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return ref.watch(danbooruPostDetailsChildrenProvider(post)).maybeWhen(
          data: (posts) => DanbooruRelatedPostsSection(
            posts: posts,
            currentPost: post,
          ),
          orElse: () => const SliverSizedBox.shrink(),
        );
  }
}

class DanbooruCharacterListSection extends ConsumerWidget {
  const DanbooruCharacterListSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return SliverCharacterPostList(tags: post.characterTags);
  }
}
