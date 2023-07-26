// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/utils.dart';
import 'package:boorusama/boorus/core/widgets/details_page_desktop.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/posts/file_details_section.dart';
import 'package:boorusama/boorus/e621/feats/favorites/favorites.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'e621_information_section.dart';
import 'e621_post_action_toolbar.dart';
import 'e621_post_details_page.dart';
import 'e621_recommended_artist_list.dart';

class E621PostDetailsDesktopPage extends ConsumerStatefulWidget {
  const E621PostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
  });

  final int initialIndex;
  final List<E621Post> posts;
  final void Function(int index) onExit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<E621PostDetailsDesktopPage> with DebounceMixin {
  late var page = widget.initialIndex;
  Timer? _debounceTimer;
  var loading = false;

  @override
  void dispose() {
    super.dispose();
    _debounceTimer?.cancel();
  }

  @override
  Widget build(BuildContext context) {
    final post = widget.posts[page];
    final auth = ref.watch(authenticationProvider);
    final isFav = ref.watch(e621FavoriteProvider(post.id));

    return CallbackShortcuts(
      bindings: {
        if (auth.isAuthenticated)
          const SingleActivator(LogicalKeyboardKey.keyF): () => !isFav
              ? ref.read(e621FavoritesProvider.notifier).add(post.id)
              : ref.read(e621FavoritesProvider.notifier).remove(post.id),
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
          setState(() {
            this.page = page;
            loading = true;
          });
          _debounceTimer?.cancel();
          _debounceTimer = Timer(const Duration(seconds: 1), () {
            ref.read(notesControllerProvider(post).notifier).load();
            setState(() => loading = false);
          });
        },
        topRightBuilder: (context) => GeneralMoreActionButton(
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
                    E621InformationSection(
                      post: post,
                    ),
                    const Divider(height: 8, thickness: 1),
                    E621PostActionToolbar(post: post),
                    const Divider(height: 8, thickness: 1),
                    E621ArtistSection(post: post),
                    //FIXME: implement stats tile
                    // Padding(
                    //   padding: const EdgeInsets.symmetric(vertical: 8),
                    //   child: DanbooruPostStatsTile(post: post),
                    // ),
                    const Divider(height: 8, thickness: 1),
                    E621TagsTile(post: post),
                    FileDetailsSection(post: post),
                    const Divider(height: 8, thickness: 1),
                  ],
                ),
              ),
              E621RecommendedArtistList(
                post: post,
                allowFetch: !loading,
              ),
            ],
          );
        },
      ),
    );
  }
}
