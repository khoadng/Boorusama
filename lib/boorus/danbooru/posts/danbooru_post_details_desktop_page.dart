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
import 'package:boorusama/core/router.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/widgets/widgets.dart';
import '../tags/details/danbooru_tags_tile.dart';

class DanbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<DanbooruPost> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<DanbooruPostDetailsDesktopPage> with DebounceMixin {
  late final currentPage = ValueNotifier(widget.initialIndex);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: currentPage,
      builder: (context, page, child) {
        final post = widget.posts[page];
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
        posts: widget.posts,
        child: _buildPage(),
      ),
    );
  }

  Widget _buildPage() {
    return PostDetailsPageDesktopScaffold(
      initialIndex: widget.initialIndex,
      posts: widget.posts,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          DanbooruMoreActionButton(
        post: post,
      ),
      toolbarBuilder: (context, post) => DanbooruPostActionToolbar(post: post),
      infoBuilder: (context, post) => SimpleInformationSection(
        post: post,
        showSource: true,
      ),
      artistInfoBuilder: (context, post) => DanbooruArtistSection(
        post: post,
        commentary:
            ref.watch(danbooruArtistCommentaryProvider(post.id)).value ??
                const ArtistCommentary.empty(),
      ),
      statsTileBuilder: (context, post) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: DanbooruPostStatsTile(
          post: post,
          commentCount: ref.watch(danbooruCommentCountProvider(post.id)).value,
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
              .map((tag) => ArtistPostList2(
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
                          orElse: () => const SliverPreviewPostGridPlaceholder(
                            
                          ),
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
    );
  }
}
