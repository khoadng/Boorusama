// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/widgets/widgets.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return true;
});

class PostDetailsPageDesktopScaffold<T extends Post>
    extends ConsumerStatefulWidget {
  const PostDetailsPageDesktopScaffold({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
    this.topRightButtonsBuilder,
    this.toolbarBuilder,
    this.artistInfoBuilder,
    this.statsTileBuilder,
    this.tagListBuilder,
    this.fileDetailsBuilder,
    this.poolTileBuilder,
    this.infoBuilder,
    this.sliverRelatedPostsBuilder,
    this.sliverArtistPostsBuilder,
    this.sliverCharacterPostsBuilder,
    required this.imageUrlBuilder,
    this.onPageLoaded,
  });

  final int initialIndex;
  final List<T> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;
  final void Function(T post)? onPageLoaded;
  final Widget Function(int currentPage, bool expanded, T post)?
      topRightButtonsBuilder;
  final Widget Function(BuildContext context, T post)? toolbarBuilder;
  final Widget Function(BuildContext context, T post)? artistInfoBuilder;
  final Widget Function(BuildContext context, T post)? statsTileBuilder;
  final Widget Function(BuildContext context, T post)? tagListBuilder;
  final Widget Function(BuildContext context, T post)? fileDetailsBuilder;
  final Widget Function(BuildContext context, T post)? poolTileBuilder;
  final Widget Function(BuildContext context, T post)? infoBuilder;

  final String Function(T post) imageUrlBuilder;

  final Widget Function(BuildContext context, T post)?
      sliverRelatedPostsBuilder;
  final List<Widget> Function(BuildContext context, T post)?
      sliverArtistPostsBuilder;
  final Widget Function(BuildContext context, T post)?
      sliverCharacterPostsBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsDesktopScaffoldState<T>();
}

class _PostDetailsDesktopScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageDesktopScaffold<T>>
    with DebounceMixin {
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
    final nextPost =
        page + 1 < widget.posts.length ? widget.posts[page + 1] : null;

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToOriginalImagePage(context, post),
      },
      child: DetailsPageDesktop(
        onShowInfoChanged: (value) => showInfo.value = value,
        onExit: widget.onExit,
        initialPage: widget.initialIndex,
        totalPages: widget.posts.length,
        onPageChanged: (page) {
          widget.onPageChanged(page);
          setState(() => this.page = page);
          ref.read(allowFetchProvider.notifier).state = false;
          _debounceTimer?.cancel();
          _debounceTimer = Timer(
            const Duration(seconds: 1),
            () {
              ref.read(allowFetchProvider.notifier).state = true;
              ref.read(notesControllerProvider(post).notifier).load();
              widget.onPageLoaded?.call(widget.posts[page]);
            },
          );
        },
        topRightBuilder: (context) =>
            widget.topRightButtonsBuilder?.call(
              page,
              showInfo.value,
              post,
            ) ??
            const SizedBox.shrink(),
        mediaBuilder: (context) {
          final noteState = ref.watch(notesControllerProvider(post));

          return Stack(
            children: [
              if (nextPost != null && !nextPost.isVideo)
                ExtendedImage.network(
                  widget.imageUrlBuilder(nextPost),
                  width: 1,
                  height: 1,
                  cacheHeight: 10,
                  cacheWidth: 10,
                  cache: true,
                ),
              PostMedia(
                post: post,
                imageUrl: widget.imageUrlBuilder(post),
                // Prevent placeholder image from showing when first loaded a post with translated image
                placeholderImageUrl:
                    post.isTranslated ? null : post.thumbnailImageUrl,
                imageOverlayBuilder: (constraints) =>
                    noteOverlayBuilderDelegate(constraints, post, noteState),
                autoPlay: true,
                inFocus: true,
              ),
            ],
          );
        },
        infoBuilder: (context) {
          return CustomScrollView(
            slivers: [
              SliverList(
                delegate: SliverChildListDelegate(
                  [
                    if (widget.infoBuilder != null)
                      widget.infoBuilder!(context, post),
                    if (widget.toolbarBuilder != null) ...[
                      const Divider(height: 8, thickness: 1),
                      widget.toolbarBuilder!(context, post),
                    ],
                    if (widget.artistInfoBuilder != null) ...[
                      const Divider(height: 8, thickness: 1),
                      widget.artistInfoBuilder!(context, post),
                    ],
                    if (widget.statsTileBuilder != null) ...[
                      const Divider(height: 8, thickness: 1),
                      widget.statsTileBuilder!(context, post),
                    ],
                    if (widget.tagListBuilder != null) ...[
                      const Divider(height: 8, thickness: 1),
                      widget.tagListBuilder!(context, post),
                    ],
                    if (widget.fileDetailsBuilder != null) ...[
                      const Divider(height: 8, thickness: 1),
                      widget.fileDetailsBuilder!(context, post),
                    ],
                    if (allowFetch)
                      if (widget.poolTileBuilder != null) ...[
                        const Divider(height: 8, thickness: 1),
                        widget.poolTileBuilder!(context, post),
                      ],
                  ],
                ),
              ),
              if (allowFetch)
                if (widget.sliverRelatedPostsBuilder != null) ...[
                  widget.sliverRelatedPostsBuilder!(context, post),
                ],
              if (allowFetch)
                if (widget.sliverArtistPostsBuilder != null)
                  ...widget.sliverArtistPostsBuilder!(context, post),
              if (allowFetch)
                if (widget.sliverCharacterPostsBuilder != null) ...[
                  widget.sliverCharacterPostsBuilder!(context, post),
                ],
              const SliverSizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }

  bool get allowFetch => ref.watch(allowFetchProvider);
}
