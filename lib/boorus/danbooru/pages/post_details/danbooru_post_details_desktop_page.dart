// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/notes/notes.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/details_page_desktop.dart';
import 'package:boorusama/boorus/core/widgets/interactive_booru_image.dart';
import 'package:boorusama/boorus/core/widgets/posts/file_details_section.dart';
import 'package:boorusama/boorus/danbooru/feats/posts/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/post_details/utils.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'danbooru_information_section.dart';
import 'danbooru_post_action_toolbar.dart';
import 'danbooru_post_details_page.dart';
import 'danbooru_recommend_artist_list.dart';
import 'danbooru_recommend_character_list.dart';
import 'related_posts_section.dart';

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
    final tags = post.extractTagDetails();
    final artists = ref.watch(danbooruPostDetailsArtistProvider(post.id));
    final characters = ref.watch(danbooruPostDetailsCharacterProvider(post.id));

    return DetailsPageDesktop(
      onExit: widget.onExit,
      initialPage: widget.initialIndex,
      totalPages: widget.posts.length,
      onPageChanged: (page) {
        setState(() => this.page = page);
        _debounceTimer?.cancel();
        _debounceTimer = Timer(const Duration(milliseconds: 700), () {
          widget.posts[page].loadDetailsFrom(ref);
          ref.read(notesControllerProvider(post).notifier).load();
        });
      },
      mediaBuilder: (context) {
        final noteState = ref.watch(notesControllerProvider(post));

        return InteractiveBooruImage(
          useHero: false,
          heroTag: "",
          aspectRatio: post.aspectRatio,
          imageUrl: post.thumbnailFromSettings(ref.read(settingsProvider)),
          // Prevent placeholder image from showing when first loaded a post with translated image
          placeholderImageUrl: post.thumbnailImageUrl,
          // currentPage == widget.intitialIndex && post.isTranslated
          //     ? null
          //     : post.thumbnailImageUrl,
          // onCached: (path) =>
          //     ref.read(postShareProvider(post).notifier).setImagePath(path ?? ''),
          previewCacheManager: ref.watch(previewImageCacheManagerProvider),
          imageOverlayBuilder: (constraints) =>
              noteOverlayBuilderDelegate(constraints, post, noteState),
          width: post.width,
          height: post.height,
        );
      },
      infoBuilder: (context) {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  DanbooruInformationSection(
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
                  TagsTile(
                      tags: tags
                          .where((e) => e.postId == post.id)
                          .map((e) => e.name)
                          .toList()),
                  FileDetailsSection(post: post),
                ],
              ),
            ),
            RelatedPostsSection(post: post),
            DanbooruRecommendArtistList(artists: artists),
            DanbooruRecommendCharacterList(characters: characters),
          ],
        );
      },
    );
  }
}
