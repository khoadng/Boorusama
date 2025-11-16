// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../../../core/artists/types.dart';
import '../../../../../../core/configs/config/providers.dart';
import '../../../../../../core/posts/details/types.dart';
import '../../../../../../core/posts/details_parts/widgets.dart';
import '../../../../../../core/widgets/booru_visibility_detector.dart';
import '../../../../artists/commentaries/providers.dart';
import '../../../../comments/comment/providers.dart';
import '../../../../pools/pool/widgets.dart';
import '../../../post/types.dart';
import '../providers.dart';
import 'danbooru_file_details.dart';
import 'danbooru_post_stats_tile.dart';
import 'danbooru_related_posts_section.dart';
import 'danbooru_tags_tile.dart';

class DanbooruPoolTiles extends ConsumerStatefulWidget {
  const DanbooruPoolTiles({super.key});

  @override
  ConsumerState<DanbooruPoolTiles> createState() => _DanbooruPoolTilesState();
}

class _DanbooruPoolTilesState extends ConsumerState<DanbooruPoolTiles> {
  late final VisibilityController _visController;

  @override
  void initState() {
    super.initState();
    _visController = VisibilityController();
  }

  @override
  void dispose() {
    _visController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final post = InheritedPost.of<DanbooruPost>(context);
    final params = (ref.watchConfigAuth, post.id);

    return MultiSliver(
      children: [
        SliverToBoxAdapter(
          child: BooruVisibilityDetector(
            childKey: Key('pool-tiles-${post.id}'),
            controller: _visController,
          ),
        ),
        SliverToBoxAdapter(
          child: ListenableBuilder(
            listenable: _visController,
            builder: (context, child) => _visController.isVisible
                ? ref
                      .watch(danbooruPostDetailsPoolsProvider(params))
                      .maybeWhen(
                        data: (pools) => PoolTiles(pools: pools),
                        orElse: () => const SizedBox.shrink(),
                      )
                : const SizedBox.shrink(),
          ),
        ),
      ],
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
