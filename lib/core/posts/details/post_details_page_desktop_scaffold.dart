// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/details/common.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
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
    this.parts = kDefaultPostDetailsParts,
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

  final Set<PostDetailsPart> parts;

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
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
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

    // on info show, fetch stuff
    controller.showInfo.addListener(_onInfoChanged);
  }

  void _onInfoChanged() {
    if (controller.showInfo.value) {
      _fetchInfo(controller.currentPage.value);
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

                // if the info is not shown, don't fetch anything
                if (!controller.showInfo.value) return;

                _fetchInfo(page);
                widget.onPageLoaded?.call(widget.posts[page]);
              },
            );
          },
          itemBuilder: (context, index) {
            final post = widget.posts[index];
            final (prevPost, nextPost) =
                widget.posts.getPrevAndNextPosts(index);

            return Stack(
              children: [
                if (nextPost != null && !nextPost.isVideo)
                  PostDetailsPreloadImage(
                    url: widget.imageUrlBuilder(nextPost),
                  ),
                if (prevPost != null && !prevPost.isVideo)
                  PostDetailsPreloadImage(
                    url: widget.imageUrlBuilder(prevPost),
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
                  onImageTap: () {
                    if (!controller.showInfo.value) {
                      controller.toggleOverlay();
                    }
                  },
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
        ...widget.parts
            .map(
              (p) => switch (p) {
                PostDetailsPart.pool => widget.poolTileBuilder != null
                    ? SliverToBoxAdapter(
                        child: widget.poolTileBuilder!(context, post),
                      )
                    : null,
                PostDetailsPart.info => widget.infoBuilder != null
                    ? SliverToBoxAdapter(
                        child: widget.infoBuilder!(context, post),
                      )
                    : null,
                PostDetailsPart.toolbar => widget.toolbarBuilder != null
                    ? SliverToBoxAdapter(
                        child: widget.toolbarBuilder!(context, post),
                      )
                    : null,
                PostDetailsPart.artistInfo => widget.artistInfoBuilder != null
                    ? SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Divider(thickness: 0.5, height: 8),
                            widget.artistInfoBuilder!(
                              context,
                              post,
                            ),
                          ],
                        ),
                      )
                    : null,
                PostDetailsPart.stats => widget.statsTileBuilder != null
                    ? SliverToBoxAdapter(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const SizedBox(height: 8),
                            widget.statsTileBuilder!(context, post),
                            const Divider(thickness: 0.5),
                          ],
                        ),
                      )
                    : null,
                PostDetailsPart.tags => widget.tagListBuilder != null
                    ? SliverToBoxAdapter(
                        child: widget.tagListBuilder!(context, post),
                      )
                    : SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: BasicTagList(
                            tags: post.tags.toList(),
                            onTap: (tag) => goToSearchPage(context, tag: tag),
                          ),
                        ),
                      ),
                PostDetailsPart.fileDetails => widget.fileDetailsBuilder != null
                    ? SliverToBoxAdapter(
                        child: Column(
                          children: [
                            widget.fileDetailsBuilder!(context, post),
                            const Divider(thickness: 0.5),
                          ],
                        ),
                      )
                    : SliverToBoxAdapter(
                        child: Column(
                          children: [
                            FileDetailsSection(
                              post: post,
                              rating: post.rating,
                            ),
                            const Divider(thickness: 0.5),
                          ],
                        ),
                      ),
                PostDetailsPart.source => widget.sourceBuilder != null
                    ? SliverToBoxAdapter(
                        child: widget.sourceBuilder!(context, post),
                      )
                    : post.source.whenWeb(
                        (source) => SliverToBoxAdapter(
                          child: SourceSection(source: source),
                        ),
                        () => null,
                      ),
                PostDetailsPart.comments => widget.commentBuilder != null
                    ? SliverToBoxAdapter(
                        child: widget.commentBuilder!(context, post),
                      )
                    : null,
                PostDetailsPart.artistPosts =>
                  widget.sliverArtistPostsBuilder != null
                      ? MultiSliver(
                          children: widget.sliverArtistPostsBuilder!(
                            context,
                            post,
                          ),
                        )
                      : null,
                PostDetailsPart.relatedPosts =>
                  widget.sliverRelatedPostsBuilder != null
                      ? widget.sliverRelatedPostsBuilder!(context, post)
                      : null,
                PostDetailsPart.characterList =>
                  widget.sliverCharacterPostsBuilder != null
                      ? widget.sliverCharacterPostsBuilder!(context, post)
                      : null,
              },
            )
            .whereNotNull(),
        const SliverSizedBox(height: 24),
      ],
    );
  }

  bool get allowFetch => ref.watch(allowFetchProvider);
}
