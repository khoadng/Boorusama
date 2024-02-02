// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/pools/pools.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/danbooru_creator_preloader.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/details/danbooru_more_action_button.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/details/danbooru_post_action_toolbar.dart';
import 'package:boorusama/boorus/danbooru/pages/widgets/details/pool_tiles.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/feats/tags/tags.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'danbooru_post_details_page.dart';
import 'widgets/danbooru_tags_tile.dart';

// import 'package:boorusama/boorus/danbooru/pages/widgets/details/danbooru_recommend_character_list.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return false;
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
    final tags = post
        .extractTagDetails()
        .where((e) => e.postId == post.id)
        .map((e) => e.name)
        .toList();

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
                ref.read(tagsProvider(booruConfig).notifier).load(tags);
                widget.posts[page].loadDetailsFrom(ref);
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
            final pools = ref.watch(allowFetchProvider)
                ? ref.watch(danbooruPostDetailsPoolsProvider(post.id))
                : const AsyncData(<Pool>[]);

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
                      DanbooruArtistSection(post: post),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: DanbooruPostStatsTile(post: post),
                      ),
                      const Divider(height: 8, thickness: 1),
                      DanbooruTagsTile(
                        allowFetch: ref.watch(allowFetchProvider),
                        post: post,
                      ),
                      DanbooruFileDetails(
                        post: post,
                      ),
                    ],
                  ),
                ),
                pools.maybeWhen(
                  data: (pools) => SliverToBoxAdapter(
                    child: PoolTiles(pools: pools),
                  ),
                  orElse: () => const SliverToBoxAdapter(),
                ),
                ref.watch(allowFetchProvider)
                    ? DanbooruRelatedPostsSection(
                        post: post,
                      )
                    : const SliverSizedBox.shrink(),
                const SliverSizedBox(height: 8),
                //Add artist back
                // artists.maybeWhen(
                //   data: (artists) =>
                //       DanbooruRecommendArtistList(artists: artists),
                //   orElse: () => const SliverToBoxAdapter(),
                // ),
                //FIXME: update desktop layout
                // characters.maybeWhen(
                //   data: (characters) =>
                //       DanbooruRecommendCharacterList(characters: characters),
                //   orElse: () => const SliverToBoxAdapter(),
                // ),
              ],
            );
          },
        ),
      ),
    );
  }
}
