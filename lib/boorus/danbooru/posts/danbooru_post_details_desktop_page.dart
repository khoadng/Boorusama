// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/artists/artists.dart';
import 'package:boorusama/boorus/danbooru/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/pools/pool_tiles.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/core/artists/artists.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../tags/details/danbooru_tags_tile.dart';

class DanbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsDesktopPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<DanbooruPostDetailsDesktopPage> with DebounceMixin {
  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<DanbooruPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return ValueListenableBuilder(
      valueListenable: controller.currentPage,
      builder: (context, page, child) {
        final post = posts[page];
        final isFav = ref.watch(danbooruFavoriteProvider(post.id));
        final booruConfig = ref.watchConfig;

        return CallbackShortcuts(
          bindings: {
            if (booruConfig.hasLoginDetails())
              const SingleActivator(LogicalKeyboardKey.keyF): () => !isFav
                  ? ref.danbooruFavorites.add(post.id)
                  : ref.danbooruFavorites.remove(post.id),
          },
          child: child!,
        );
      },
      child: DanbooruCreatorPreloader(
        posts: posts,
        child: _buildPage(
          posts: posts,
          controller: controller,
        ),
      ),
    );
  }

  Widget _buildPage({
    required List<DanbooruPost> posts,
    required PostDetailsController<DanbooruPost> controller,
  }) {
    return PostDetailsPageDesktopScaffold(
      controller: controller,
      posts: posts,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          DanbooruMoreActionButton(
        post: post,
      ),
      infoBuilder: (context, post) => SimpleInformationSection(
        post: post,
        showSource: true,
      ),
      artistInfoBuilder: (context, post) => DanbooruArtistSection(
        post: post,
        commentary:
            ref.watch(danbooruArtistCommentaryProvider(post.id)).maybeWhen(
                  data: (commentary) => commentary,
                  orElse: () => const ArtistCommentary.empty(),
                ),
      ),
      statsTileBuilder: (context, post) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DanbooruPostStatsTile(
          post: post,
          commentCount:
              ref.watch(danbooruCommentCountProvider(post.id)).maybeWhen(
                    data: (count) => count,
                    orElse: () => null,
                  ),
        ),
      ),
      tagListBuilder: (context, post) => DanbooruTagsTile(
        post: post,
      ),
      fileDetailsBuilder: (context, post) => DanbooruFileDetails(
        post: post,
      ),
      poolTileBuilder: (context, post) =>
          ref.watch(danbooruPostDetailsPoolsProvider(post.id)).maybeWhen(
                data: (pools) => PoolTiles(pools: pools),
                orElse: () => const SizedBox.shrink(),
              ),
      sliverRelatedPostsBuilder: (context, post) =>
          ref.watch(danbooruPostDetailsChildrenProvider(post)).maybeWhen(
                data: (posts) => DanbooruRelatedPostsSection(
                  posts: posts,
                  currentPost: post,
                ),
                orElse: () => const SliverSizedBox.shrink(),
              ),
      sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
          ? post.artistTags
              .map((tag) => ArtistPostList(
                    tag: tag,
                    builder: (tag) => ref
                        .watch(danbooruPostDetailsArtistProvider(tag))
                        .maybeWhen(
                          data: (data) => SliverPreviewPostGrid(
                            posts: data,
                            onTap: (postIdx) => goToPostDetailsPage(
                              context: context,
                              posts: data,
                              initialIndex: postIdx,
                            ),
                            imageUrl: (item) => item.url360x360,
                          ),
                          orElse: () =>
                              const SliverPreviewPostGridPlaceholder(),
                        ),
                  ))
              .toList()
          : [],
      sliverCharacterPostsBuilder: (context, post) => post.artistTags.isEmpty
          ? CharacterPostList(tags: post.characterTags)
          : ref
              .watch(danbooruPostDetailsArtistProvider(post.artistTags.first))
              .maybeWhen(
                data: (_) => CharacterPostList(tags: post.characterTags),
                orElse: () => const SliverSizedBox.shrink(),
              ),
      parts: kDefaultPostDetailsNoSourceParts,
    );
  }
}
