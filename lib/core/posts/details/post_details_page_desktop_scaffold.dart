// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/tags/tags.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return true;
});

class DefaultPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const DefaultPostDetailsDesktopPage({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.onExit,
    required this.onPageChanged,
  });

  final int initialIndex;
  final List<Post> posts;
  final void Function(int index) onExit;
  final void Function(int page) onPageChanged;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DefaultPostDetailsDesktopPageState();
}

class _DefaultPostDetailsDesktopPageState
    extends ConsumerState<DefaultPostDetailsDesktopPage> {
  @override
  Widget build(BuildContext context) {
    return PostDetailsPageDesktopScaffold(
      posts: widget.posts,
      initialIndex: widget.initialIndex,
      onExit: widget.onExit,
      onPageChanged: widget.onPageChanged,
      imageUrlBuilder: (post) => post.sampleImageUrl,
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
      toolbarBuilder: (context, post) => SimplePostActionToolbar(post: post),
      tagListBuilder: (context, post) => BasicTagList(
        tags: post.tags.toList(),
        onTap: (tag) => goToSearchPage(context, tag: tag),
      ),
      fileDetailsBuilder: (context, post) => FileDetailsSection(
        post: post,
        rating: post.rating,
      ),
    );
  }
}

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
    this.sourceBuilder,
    this.commentBuilder,
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
  final Widget Function(BuildContext context, T post)? sourceBuilder;
  final Widget Function(BuildContext context, T post)? commentBuilder;
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
  Timer? _debounceTimer;
  late final controller = DetailsPageDesktopController(
    initialPage: widget.initialIndex,
    totalPages: widget.posts.length,
  );
  late final pageController = PageController(initialPage: widget.initialIndex);

  late StreamSubscription<PageDirection> _pageSubscription;

  @override
  void initState() {
    super.initState();
    _pageSubscription = controller.pageStream.listen((event) {
      if (event == PageDirection.next) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      } else {
        pageController.previousPage(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    _debounceTimer?.cancel();
    _pageSubscription.cancel();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToOriginalImagePage(
              context,
              widget.posts[controller.currentPage.value],
            ),
      },
      child: DetailsPageDesktop(
        controller: controller,
        onExit: widget.onExit,
        initialPage: widget.initialIndex,
        totalPages: widget.posts.length,
        topRight: ValueListenableBuilder(
          valueListenable: controller.currentPage,
          builder: (context, page, child) {
            return ValueListenableBuilder(
              valueListenable: controller.showInfo,
              builder: (context, value, child) {
                return widget.topRightButtonsBuilder?.call(
                      page,
                      value,
                      widget.posts[page],
                    ) ??
                    const SizedBox.shrink();
              },
            );
          },
        ),
        media: PageView.builder(
          controller: pageController,
          itemCount: widget.posts.length,
          onPageChanged: (page) {
            ref.read(allowFetchProvider.notifier).state = false;
            _debounceTimer?.cancel();
            _debounceTimer = Timer(
              const Duration(seconds: 1),
              () {
                widget.onPageChanged(page);
                controller.changePage(page);
                final post = widget.posts[page];
                ref.read(allowFetchProvider.notifier).state = true;
                ref.read(notesControllerProvider(post).notifier).load();
                widget.onPageLoaded?.call(widget.posts[page]);
              },
            );
          },
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            final nextPost = index + 1 < widget.posts.length
                ? widget.posts[index + 1]
                : null;

            return Stack(
              children: [
                if (nextPost != null && !nextPost.isVideo)
                  ExtendedImage.network(
                    widget.imageUrlBuilder(nextPost),
                    width: 1,
                    height: 1,
                    cacheHeight: 10,
                    cacheWidth: 10,
                  ),
                PostMedia(
                  post: post,
                  imageUrl: widget.imageUrlBuilder(post),
                  // Prevent placeholder image from showing when first loaded a post with translated image
                  placeholderImageUrl:
                      post.isTranslated ? null : post.thumbnailImageUrl,
                  imageOverlayBuilder: (constraints) =>
                      noteOverlayBuilderDelegate(
                    constraints,
                    post,
                    ref.watch(notesControllerProvider(post)),
                  ),
                  autoPlay: true,
                  inFocus: true,
                ),
              ],
            );
          },
        ),
        info: ValueListenableBuilder(
          valueListenable: controller.showInfo,
          builder: (context, value, child) => value
              ? ValueListenableBuilder(
                  valueListenable: controller.currentPage,
                  builder: (context, page, child) =>
                      _buildInfo(context, widget.posts[page]),
                )
              : const SizedBox.shrink(),
        ),
      ),
    );
  }

  Widget _buildInfo(BuildContext context, T post) {
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
              if (allowFetch)
                if (widget.poolTileBuilder != null) ...[
                  widget.poolTileBuilder!(context, post),
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
  }

  bool get allowFetch => ref.watch(allowFetchProvider);
}
