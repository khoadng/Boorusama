// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/debounce_mixin.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

final allowFetchProvider = StateProvider<bool>((ref) {
  return true;
});

class DefaultPostDetailsDesktopPage extends ConsumerStatefulWidget {
  const DefaultPostDetailsDesktopPage({
    super.key,
  });

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _DefaultPostDetailsDesktopPageState();
}

class _DefaultPostDetailsDesktopPageState
    extends ConsumerState<DefaultPostDetailsDesktopPage> {
  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<Post>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageDesktopScaffold(
      controller: controller,
      posts: posts,
      imageUrlBuilder: (post) => post.sampleImageUrl,
      topRightButtonsBuilder: (currentPage, expanded, post) =>
          GeneralMoreActionButton(post: post),
    );
  }
}

class PostDetailsPageDesktopScaffold<T extends Post>
    extends ConsumerStatefulWidget {
  const PostDetailsPageDesktopScaffold({
    super.key,
    required this.posts,
    this.topRightButtonsBuilder,
    required this.imageUrlBuilder,
    this.onPageLoaded,
    this.debounceDuration,
    required this.controller,
    this.uiBuilder,
  });

  final List<T> posts;
  final void Function(T post)? onPageLoaded;
  final Widget Function(int currentPage, bool expanded, T post)?
      topRightButtonsBuilder;
  final String Function(T post) imageUrlBuilder;
  final Duration? debounceDuration;
  final PostDetailsController<T> controller;
  final PostDetailsUIBuilder? uiBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PostDetailsDesktopScaffoldState<T>();
}

class _PostDetailsDesktopScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageDesktopScaffold<T>>
    with DebounceMixin {
  Timer? _debounceTimer;
  late final controller = DetailsPageDesktopController(
    totalPageFetcher: () => widget.posts.length,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
    initialPage: widget.controller.initialPage,
    pageSyncronizer: widget.controller.setPage,
  );
  late final pageController =
      PageController(initialPage: widget.controller.initialPage);

  late StreamSubscription<PageDirection> _pageSubscription;

  @override
  void initState() {
    super.initState();
    _pageSubscription = controller.pageStream.listen((event) {
      final currentRealtimePage = controller.currentRealtimePage.value;
      final pageIndex = switch (event) {
        PageDirection.next => currentRealtimePage + 1,
        PageDirection.previous => currentRealtimePage - 1,
      };

      if (pageIndex >= 0 && pageIndex < widget.posts.length) {
        pageController.jumpToPage(pageIndex);
      }
    });

    // on info show, fetch stuff
    controller.showInfo.addListener(_onInfoChanged);
  }

  void _onInfoChanged() {
    if (controller.showInfo.value) {
      _fetchInfo(controller.currentLocalPage.value);
    }
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
    _debounceTimer?.cancel();
    _pageSubscription.cancel();
    controller.showInfo.removeListener(_onInfoChanged);
    controller.dispose();
  }

  void _fetchInfo(int page) {
    final post = widget.posts[page];
    ref.read(allowFetchProvider.notifier).state = true;
    ref.read(notesControllerProvider(post).notifier).load();
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
              widget.posts[controller.currentLocalPage.value],
            ),
      },
      child: DetailsPageDesktop(
        controller: controller,
        onExit: widget.controller.onExit,
        totalPages: widget.posts.length,
        topRight: ValueListenableBuilder(
          valueListenable: controller.currentLocalPage,
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
        media: _buildMedia(),
        info: Builder(
          builder: (context) => ValueListenableBuilder(
            valueListenable: controller.showInfo,
            builder: (context, expanded, _) => PostDetailsFullInfoSheet(
              expanded: expanded,
              uiBuilder: widget.uiBuilder,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMedia() {
    final booruBuilder = ref.watch(booruBuilderProvider);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;

    return ValueListenableBuilder(
      valueListenable: controller.pageSwipe,
      builder: (_, swipe, __) => PageView.builder(
        controller: pageController,
        itemCount: widget.posts.length,
        physics: swipe ? null : const NeverScrollableScrollPhysics(),
        onPageChanged: (page) {
          controller.changeRealtimePage(page);
          ref.read(allowFetchProvider.notifier).state = false;
          _debounceTimer?.cancel();
          _debounceTimer = Timer(
            widget.debounceDuration ?? const Duration(seconds: 1),
            () {
              controller.changePage(page);

              // if the info is not shown, don't fetch anything
              if (!controller.showInfo.value) return;

              _fetchInfo(page);
              widget.onPageLoaded?.call(widget.posts[page]);
            },
          );
        },
        itemBuilder: (context, index) {
          final post = widget.posts[index];
          final (prevPost, nextPost) = widget.posts.getPrevAndNextPosts(index);

          return Stack(
            alignment: Alignment.center,
            children: [
              if (nextPost != null && !nextPost.isVideo)
                PostDetailsPreloadImage(
                  url: widget.imageUrlBuilder(nextPost),
                ),
              if (prevPost != null && !prevPost.isVideo)
                PostDetailsPreloadImage(
                  url: widget.imageUrlBuilder(prevPost),
                ),
              InteractiveViewExtended(
                onZoomUpdated: onZoomUpdated,
                onTap: () {
                  if (!controller.showInfo.value) {
                    controller.toggleOverlay();
                  }
                },
                onDoubleTap: booruBuilder?.canHandlePostGesture(
                              GestureType.doubleTap,
                              ref.watchConfig.postGestures?.fullview,
                            ) ==
                            true &&
                        postGesturesHandler != null
                    ? () => postGesturesHandler(
                          ref,
                          ref.watchConfig.postGestures?.fullview?.doubleTap,
                          post,
                        )
                    : null,
                onLongPress: booruBuilder?.canHandlePostGesture(
                              GestureType.longPress,
                              ref.watchConfig.postGestures?.fullview,
                            ) ==
                            true &&
                        postGesturesHandler != null
                    ? () => postGesturesHandler(
                          ref,
                          ref.watchConfig.postGestures?.fullview?.longPress,
                          post,
                        )
                    : null,
                child: PostMedia(
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
              ),
            ],
          );
        },
      ),
    );
  }

  void onZoomUpdated(bool zoom) {
    controller.setEnablePageSwipe(!zoom);
  }

  bool get allowFetch => ref.watch(allowFetchProvider);
}
