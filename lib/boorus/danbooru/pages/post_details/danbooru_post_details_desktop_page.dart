// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/details_page_desktop.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/posts/file_details_section.dart';
import 'package:boorusama/boorus/core/widgets/posts/information_section.dart';
import 'package:boorusama/boorus/danbooru/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/post_details/pool_tiles.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'danbooru_more_action_button.dart';
import 'danbooru_post_action_toolbar.dart';
import 'danbooru_post_details_page.dart';
import 'danbooru_recommend_artist_list.dart';
import 'danbooru_recommend_character_list.dart';

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
    final artists = ref.watch(danbooruPostDetailsArtistProvider(post));
    final characters = ref.watch(danbooruPostDetailsCharacterProvider(post));
    final pools = ref.watch(danbooruPostDetailsPoolsProvider(post.id));
    final auth = ref.watch(authenticationProvider);
    final isFav = ref.watch(danbooruFavoriteProvider(post.id));
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return CallbackShortcuts(
      bindings: {
        if (auth.isAuthenticated)
          const SingleActivator(LogicalKeyboardKey.keyF): () => !isFav
              ? ref.danbooruFavorites.add(post.id)
              : ref.danbooruFavorites.remove(post.id),
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToOriginalImagePage(context, post),
      },
      child: DetailsPageDesktop(
        onExit: widget.onExit,
        initialPage: widget.initialIndex,
        totalPages: widget.posts.length,
        onPageChanged: (page) {
          setState(() => this.page = page);
          ref.read(tagsProvider(booruConfig).notifier).load(tags);
          _debounceTimer?.cancel();
          _debounceTimer = Timer(
            const Duration(seconds: 1),
            () {
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
                    DanbooruArtistSection(post: post),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: DanbooruPostStatsTile(post: post),
                    ),
                    const Divider(height: 8, thickness: 1),
                    TagsTile(tags: tags),
                    FileDetailsSection(post: post),
                  ],
                ),
              ),
              pools.maybeWhen(
                data: (pools) => SliverToBoxAdapter(
                  child: PoolTiles(pools: pools),
                ),
                orElse: () => const SliverToBoxAdapter(),
              ),
              artists.maybeWhen(
                data: (artists) =>
                    DanbooruRecommendArtistList(artists: artists),
                orElse: () => const SliverToBoxAdapter(),
              ),
              characters.maybeWhen(
                data: (characters) =>
                    DanbooruRecommendCharacterList(characters: characters),
                orElse: () => const SliverToBoxAdapter(),
              ),
            ],
          );
        },
      ),
    );
  }
}
