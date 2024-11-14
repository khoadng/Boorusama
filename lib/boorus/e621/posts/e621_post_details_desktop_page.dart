// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/e621/artists/artists.dart';
import 'package:boorusama/boorus/e621/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/router.dart';

class E621PostDetailsDesktopPage extends ConsumerStatefulWidget {
  const E621PostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
    required this.controller,
  });

  final int initialIndex;
  final List<E621Post> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;
  final PostDetailsController<E621Post> controller;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DanbooruPostDetailsDesktopPageState();
}

class _DanbooruPostDetailsDesktopPageState
    extends ConsumerState<E621PostDetailsDesktopPage> {
  @override
  Widget build(BuildContext context) {
    return PostDetailsPageDesktopScaffold(
      posts: widget.posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      onPageLoaded: (post) {
        ref.read(notesControllerProvider(post).notifier).load();
      },
      imageUrlBuilder: defaultPostImageUrlBuilder(ref),
      infoBuilder: (context, post) => SimpleInformationSection(post: post),
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      tagListBuilder: (context, post) => E621TagsTile(
        post: post,
      ),
      sliverArtistPostsBuilder: (context, post) => post.artistTags.isNotEmpty
          ? post.artistTags
              .map(
                (tag) => ArtistPostList(
                  tag: tag,
                  builder: (tag) => ref
                      .watch(e621ArtistPostsProvider(tag))
                      .maybeWhen(
                        data: (data) => SliverPreviewPostGrid(
                          posts: data,
                          onTap: (postIdx) => goToPostDetailsPage(
                            context: context,
                            posts: data,
                            initialIndex: postIdx,
                          ),
                          imageUrl: (item) => item.thumbnailFromSettings(
                              ref.watch(imageListingSettingsProvider)),
                        ),
                        orElse: () => const SliverPreviewPostGridPlaceholder(),
                      ),
                ),
              )
              .toList()
          : [],
      parts: kDefaultPostDetailsNoSourceParts,
    );
  }
}
