// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/tags/tags.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/core/widgets/details_page_desktop.dart';
import 'package:boorusama/boorus/core/widgets/general_more_action_button.dart';
import 'package:boorusama/boorus/core/widgets/post_media.dart';
import 'package:boorusama/boorus/core/widgets/posts/file_details_section.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/widgets/basic_tag_list.dart';
import 'widgets/gelbooru_post_action_toolbar.dart';
import 'widgets/gelbooru_recommend_artist_list.dart';
import 'widgets/tags_tile.dart';

class GelbooruPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const GelbooruPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    this.hasDetailsTagList = true,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int index) onExit;
  final bool hasDetailsTagList;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<GelbooruPostDetailsDesktopPage> with DebounceMixin {
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
    final booruConfig = ref.watch(currentBooruConfigProvider);

    return CallbackShortcuts(
      bindings: {
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
          _debounceTimer = Timer(
            const Duration(seconds: 1),
            () {
              if (widget.hasDetailsTagList) {
                ref.read(tagsProvider(booruConfig).notifier).load(
                  widget.posts[page].tags,
                  onSuccess: (tags) {
                    if (!mounted) return;
                    widget.posts[page].loadArtistPostsFrom(ref, tags);
                    setState(() => loading = false);
                  },
                );
              }
            },
          );
        },
        topRightBuilder: (context) => GeneralMoreActionButton(
          post: post,
        ),
        mediaBuilder: (context) {
          return PostMedia(
            post: post,
            imageUrl: post.sampleImageUrl,
            placeholderImageUrl: post.thumbnailImageUrl,
            autoPlay: true,
          );
        },
        infoBuilder: (context) {
          final artists = ref.watch(booruPostDetailsArtistProvider(post.id));

          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    FileDetailsSection(post: post),
                    const Divider(height: 8, thickness: 1),
                    GelbooruPostActionToolbar(post: post),
                    const Divider(height: 8, thickness: 1),
                    if (widget.hasDetailsTagList)
                      TagsTile(
                        tags: loading
                            ? null
                            : ref.watch(tagsProvider(booruConfig)),
                        initialExpanded: true,
                        post: post,
                        onTagTap: (tag) => goToSearchPage(
                          context,
                          tag: tag.rawName,
                        ),
                      )
                    else
                      BasicTagList(
                        tags: post.tags,
                        onTap: (tag) => goToSearchPage(context, tag: tag),
                      ),
                  ],
                ),
              ),
              GelbooruRecommendedArtistList(artists: artists),
            ],
          );
        },
      ),
    );
  }
}
