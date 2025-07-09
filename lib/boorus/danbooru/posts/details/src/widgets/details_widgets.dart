// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../../../core/artists/types.dart';
import '../../../../../../core/configs/ref.dart';
import '../../../../../../core/posts/details/details.dart';
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
    final params = (ref.watchConfigAuth, post.id);

    return SliverToBoxAdapter(
      child: ref
          .watch(danbooruPostDetailsPoolsProvider(params))
          .maybeWhen(
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
    final params = (ref.watchConfigAuth, post.id);

    return SliverToBoxAdapter(
      child: ArtistSection(
        commentary: ref
            .watch(danbooruArtistCommentaryProvider(params))
            .maybeWhen(
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
    final params = (ref.watchConfigAuth, post.id);

    return SliverToBoxAdapter(
      child: DanbooruPostStatsTile(
        post: post,
        commentCount: ref
            .watch(danbooruCommentCountProvider(params))
            .valueOrNull,
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

class DanbooruRelatedPostsSection2 extends ConsumerWidget {
  const DanbooruRelatedPostsSection2({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<DanbooruPost>(context);

    return ref
        .watch(
          danbooruPostDetailsChildrenProvider(
            (ref.watchConfigFilter, ref.watchConfigSearch, post),
          ),
        )
        .maybeWhen(
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
