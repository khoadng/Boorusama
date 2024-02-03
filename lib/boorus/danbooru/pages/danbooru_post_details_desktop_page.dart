// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:boorusama/boorus/danbooru/feats/artist_commentaries/artist_commentaries.dart';
import 'package:boorusama/core/feats/artist_commentaries/artist_commentaries.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/comments/comments.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_creator_preloader.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/details/danbooru_more_action_button.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/details/danbooru_post_action_toolbar.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/details/pool_tiles.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'danbooru_post_details_page.dart';
import 'widgets/danbooru_tags_tile.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return true;
});

class DanbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const DanbooruPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
  });

  final int initialIndex;
  final List<DanbooruPost> posts;
  final void Function(int index) onExit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<DanbooruPostDetailsDesktopPage> with DebounceMixin {
  late var page = widget.initialIndex;
  Timer? _debounceTimer;
  final showInfo = ValueNotifier(false);

  @override
  void dispose() {
    super.dispose();
    _debounceTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[page];
    final isFav = ref.watch(danbooruFavoriteProvider(post.id));
    final booruConfig = ref.watchConfig;

    return CallbackShortcuts(
      bindings: {
        if (booruConfig.hasLoginDetails())
          const SingleActivator(LogicalKeyboardKey.keyF): () => !isFav
              ? ref.danbooruFavorites.add(post.id)
              : ref.danbooruFavorites.remove(post.id),
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToOriginalImagePage(context, post),
      },
      child: DanbooruCreatorPreloader(
        posts: widget.posts,
        child: DetailsPageDesktop(
          onShowInfoChanged: (value) => showInfo.value = value,
          onExit: widget.onExit,
          initialPage: widget.initialIndex,
          totalPages: widget.posts.length,
          onPageChanged: (page) {
            setState(() => this.page = page);
            ref.read(allowFetchProvider.notifier).state = false;
            _debounceTimer?.cancel();
            _debounceTimer = Timer(
              const Duration(seconds: 1),
              () {
                ref.read(allowFetchProvider.notifier).state = true;
                ref.read(notesControllerProvider(post).notifier).load();
              },
            );
          },
          topRightBuilder: (context) => DanbooruMoreActionButton(
            post: post,
          ),
          mediaBuilder: (context) {
            final noteState = ref.watch(notesControllerProvider(post));

            return PostMedia(
              post: post,
              imageUrl: post.sampleImageUrl,
              // Prevent placeholder image from showing when first loaded a post with translated image
              placeholderImageUrl:
                  post.isTranslated ? null : post.thumbnailImageUrl,
              imageOverlayBuilder: (constraints) =>
                  noteOverlayBuilderDelegate(constraints, post, noteState),
              autoPlay: true,
              inFocus: true,
            );
          },
          infoBuilder: (context) {
            return CustomScrollView(
              slivers: [
                SliverList(
                  delegate: SliverChildListDelegate(
                    [
                      SimpleInformationSection(
                        post: post,
                        showSource: true,
                      ),
                      const Divider(height: 8, thickness: 1),
                      RepaintBoundary(
                        child: DanbooruPostActionToolbar(post: post),
                      ),
                      const Divider(height: 8, thickness: 1),
                      DanbooruArtistSection(
                        post: post,
                        commentary: ref
                                .watch(
                                    danbooruArtistCommentaryProvider(post.id))
                                .value ??
                            ArtistCommentary.empty(),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: DanbooruPostStatsTile(
                          post: post,
                          commentCount: ref
                              .watch(danbooruCommentCountProvider(post.id))
                              .value,
                        ),
                      ),
                      const Divider(height: 8, thickness: 1),
                      DanbooruTagsTile(
                        post: post,
                      ),
                      DanbooruFileDetails(
                        post: post,
                      ),
                    ],
                  ),
                ),
                if (allowFetch)
                  ref
                      .watch(danbooruPostDetailsPoolsProvider(post.id))
                      .maybeWhen(
                        data: (pools) => SliverToBoxAdapter(
                          child: PoolTiles(pools: pools),
                        ),
                        orElse: () => const SliverToBoxAdapter(),
                      ),
                if (allowFetch)
                  DanbooruRelatedPostsSection(
                    post: post,
                  ),
                const SliverSizedBox(height: 8),
                if (allowFetch)
                  post.artistTags.isNotEmpty
                      ? ArtistPostList(
                          artists: post.artistTags,
                          builder: (tag) => ref
                              .watch(danbooruPostDetailsArtistProvider(tag))
                              .maybeWhen(
                                data: (data) => PreviewPostGrid(
                                  posts: data,
                                  onTap: (postIdx) => goToPostDetailsPage(
                                    context: context,
                                    posts: data,
                                    initialIndex: postIdx,
                                  ),
                                  imageUrl: (item) => item.url360x360,
                                ),
                                orElse: () => const PreviewPostGridPlaceholder(
                                  imageCount: 30,
                                ),
                              ),
                        )
                      : const SliverSizedBox.shrink(),
                if (allowFetch)
                  post.artistTags.isEmpty
                      ? DanbooruCharacterPostList(post: post)
                      : ref
                          .watch(danbooruPostDetailsArtistProvider(
                              post.artistTags.first))
                          .maybeWhen(
                            data: (_) => DanbooruCharacterPostList(post: post),
                            orElse: () => const SliverSizedBox.shrink(),
                          ),
                const SliverSizedBox(height: 24),
              ],
            );
          },
        ),
      ),
    );
  }

  bool get allowFetch => ref.watch(allowFetchProvider);
}
