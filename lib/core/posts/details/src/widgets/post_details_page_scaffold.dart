// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../../foundation/platform.dart';
import '../../../../analytics/providers.dart';
import '../../../../boorus/engine/engine.dart';
import '../../../../cache/providers.dart';
import '../../../../configs/config.dart';
import '../../../../configs/gesture/gesture.dart';
import '../../../../premiums/providers.dart';
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../theme.dart';
import '../../../../widgets/widgets.dart';
import '../../../details_manager/types.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../../../post/routes.dart';
import '../../details.dart';
import 'post_details_controller.dart';
import 'post_details_full_info_sheet.dart';
import 'video_controls.dart';
import 'volume_key_page_navigator.dart';

const String kShowInfoStateCacheKey = 'showInfoCacheStateKey';

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    required this.posts,
    required this.controller,
    required this.gestureConfig,
    required this.layoutConfig,
    required this.itemBuilder,
    required this.transformController,
    required this.isInitPage,
    required this.actions,
    required this.postGestureHandlerBuilder,
    required this.uiBuilder,
    super.key,
    this.onExpanded,
    this.preferredParts,
    this.preferredPreviewParts,
  });

  final List<T> posts;
  final void Function()? onExpanded;
  final PostDetailsController<T> controller;
  final PostDetailsUIBuilder? uiBuilder;
  final Set<DetailsPart>? preferredParts;
  final Set<DetailsPart>? preferredPreviewParts;
  final LayoutConfigs? layoutConfig;
  final PostGestureConfig? gestureConfig;
  final IndexedWidgetBuilder itemBuilder;
  final TransformationController transformController;
  final ValueNotifier<bool> isInitPage;
  final List<Widget> actions;
  final PostGestureHandlerBuilder? postGestureHandlerBuilder;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>> {
  late final _posts = widget.posts;

  PostDetailsPageViewController? _pageViewController;
  PostDetailsPageViewController get _controller {
    return _pageViewController ??= PostDetailsPageViewScope.of(context);
  }

  VolumeKeyPageNavigator? _volumeKeyPageNavigator;

  ValueNotifier<bool> visibilityNotifier = ValueNotifier(false);
  late final _isInitPage = widget.isInitPage;

  List<T> get posts => _posts;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final useDefaultEngine = ref.read(
        settingsProvider.select((value) => value.mediaKitHardwareDecoding),
      );

      widget.controller.setPage(
        widget.controller.initialPage,
        useDefaultEngine: useDefaultEngine,
      );
    });

    widget.controller.isVideoPlaying.addListener(_isVideoPlayingChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    _volumeKeyPageNavigator ??= VolumeKeyPageNavigator(
      pageViewController: _controller,
      totalPosts: _posts.length,
      visibilityNotifier: visibilityNotifier,
      enableVolumeKeyViewerNavigation: () => ref.read(
        settingsProvider.select((value) => value.volumeKeyViewerNavigation),
      ),
    )..initialize();
  }

  @override
  void dispose() {
    _volumeKeyPageNavigator?.dispose();
    widget.controller.isVideoPlaying.removeListener(_isVideoPlayingChanged);

    super.dispose();
  }

  var _previouslyPlaying = false;

  void _isVideoPlayingChanged() {
    if (context.isLargeScreen && isDesktopPlatform()) {
      // force overlay to be on when video is not playing
      if (!widget.controller.isVideoPlaying.value) {
        _controller.disableHoverToControlOverlay();
      } else {
        if (widget.controller.currentPost.value.isVideo) {
          _controller.enableHoverToControlOverlay();
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final useDefaultEngine = ref.watch(
      settingsProvider.select(
        (value) => value.mediaKitHardwareDecoding,
      ),
    );

    // Sync slideshow options with settings
    ref.listen(
      settingsProvider.select(
        toSlideShowOptions,
      ),
      (prev, next) {
        if (prev != next) {
          _controller.slideshowOptions = next;
        }
      },
    );

    return CallbackShortcuts(
      bindings: {
        const SingleActivator(
          LogicalKeyboardKey.keyF,
          control: true,
        ): () => goToOriginalImagePage(
          ref,
          widget.posts[_controller.page],
        ),
      },
      child: CustomContextMenuOverlay(
        backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        child: VisibilityDetector(
          key: const Key('post_details_page_scaffold'),
          onVisibilityChanged: (info) {
            if (!mounted) return;

            if (info.visibleFraction == 0) {
              visibilityNotifier.value = false;
              _previouslyPlaying = widget.controller.isVideoPlaying.value;
              if (_previouslyPlaying) {
                widget.controller.pauseCurrentVideo(
                  useDefaultEngine: useDefaultEngine,
                );
              }
            } else if (info.visibleFraction == 1) {
              visibilityNotifier.value = true;
              if (_previouslyPlaying) {
                widget.controller.playCurrentVideo(
                  useDefaultEngine: useDefaultEngine,
                );
              }
            }
          },
          child: _build(),
        ),
      ),
    );
  }

  Widget _build() {
    final postGesturesHandler = widget.postGestureHandlerBuilder;
    final gestures = widget.gestureConfig?.fullview;

    final uiBuilder = widget.uiBuilder;

    final useDefaultEngineForPageChange = ref.watch(
      settingsProvider.select((value) => value.mediaKitHardwareDecoding),
    );
    final reduceAnimations = ref.watch(
      settingsProvider.select((value) => value.reduceAnimations),
    );
    final swipeMode = ref.watch(
      settingsProvider.select((value) => value.swipeMode),
    );

    return Scaffold(
      body: PostDetailsPageView(
        viewMode: switch (swipeMode) {
          PostDetailsSwipeMode.horizontal => ViewMode.horizontal,
          PostDetailsSwipeMode.vertical => ViewMode.vertical,
        },
        disableAnimation: reduceAnimations,
        onPageChanged: (page) {
          final post = posts[page];

          widget.controller.setPage(
            page,
            useDefaultEngine: useDefaultEngineForPageChange,
          );

          _isInitPage.value = false;

          if (_controller.overlay.value) {
            if (post.isVideo) {
              _controller.enableHoverToControlOverlay();
            } else {
              _controller.disableHoverToControlOverlay();
            }
          }
        },
        sheetStateStorage: SheetStateStorageBuilder(
          save: (expanded) => ref
              .read(miscDataProvider(kShowInfoStateCacheKey).notifier)
              .put(expanded.toString()),
          load: () =>
              ref.read(miscDataProvider(kShowInfoStateCacheKey)) == 'true',
        ),
        checkIfLargeScreen: () => context.isLargeScreen,
        controller: _controller,
        onExit: () {
          widget.controller.onExit();
        },
        itemCount: posts.length,
        leftActions: [
          CircularIconButton(
            icon: const Icon(
              Symbols.home,
              fill: 1,
            ),
            onPressed: () => goToHomePage(ref),
          ),
          const SizedBox(width: 8),
          if (widget.controller.dislclaimer != null)
            CircularIconButton(
              icon: const Icon(
                Symbols.warning,
                fill: 1,
              ),
              onPressed: () => showAppModalBarBottomSheet(
                context: context,
                builder: (_) => DisclaimerDialog(
                  disclaimer: widget.controller.dislclaimer!,
                ),
              ),
            ),
        ],
        onSwipeDownThresholdReached:
            gestures.canSwipeDown && postGesturesHandler != null
            ? () {
                _controller.resetSheet();

                postGesturesHandler(
                  ref,
                  gestures?.swipeDown,
                  posts[_controller.page],
                );
              }
            : null,
        sheetBuilder: (context, scrollController) {
          return Consumer(
            builder: (_, ref, _) {
              final layoutDetails = widget.layoutConfig?.details;

              final preferredParts =
                  widget.preferredParts ??
                  getLayoutParsedParts(
                    details: layoutDetails,
                    hasPremium: ref.watch(hasPremiumLayoutProvider),
                  ) ??
                  uiBuilder?.full.keys.toSet();

              return ValueListenableBuilder(
                valueListenable: _controller.sheetState,
                builder: (context, state, _) => PostDetailsFullInfoSheet(
                  scrollController: scrollController,
                  sheetState: state,
                  uiBuilder: uiBuilder,
                  preferredParts: preferredParts,
                  canCustomize: ref.watch(showPremiumFeatsProvider),
                ),
              );
            },
          );
        },
        itemBuilder: widget.itemBuilder,
        bottomSheet: Consumer(
          builder: (_, ref, _) {
            final layoutPreviewDetails = widget.layoutConfig?.previewDetails;

            return widget.uiBuilder != null
                ? _buildCustomPreview(widget.uiBuilder!, layoutPreviewDetails)
                : uiBuilder != null && uiBuilder.preview.isNotEmpty
                ? _buildCustomPreview(uiBuilder, layoutPreviewDetails)
                : _buildFallbackPreview();
          },
        ),
        actions: widget.actions,
        onExpanded: () {
          widget.onExpanded?.call();
          // Reset zoom when expanded
          widget.transformController.value = Matrix4.identity();
          ref
              .read(analyticsProvider)
              .whenData(
                (analytics) => analytics?.logScreenView('/details/info'),
              );
        },
        onShrink: () {
          final routeName = ModalRoute.of(context)?.settings.name;
          if (routeName != null) {
            ref
                .read(analyticsProvider)
                .whenData(
                  (analytics) => analytics?.logScreenView(routeName),
                );
          }
        },
      ),
    );
  }

  Widget _buildCustomPreview(
    PostDetailsUIBuilder uiBuilder,
    List<CustomDetailsPartKey>? layoutPreviewDetails,
  ) {
    final preferredPreviewParts =
        widget.preferredPreviewParts ??
        getLayoutPreviewParsedParts(
          previewDetails: layoutPreviewDetails,
          hasPremium: ref.watch(hasPremiumLayoutProvider),
        ) ??
        uiBuilder.preview.keys.toSet();

    final colorScheme = Theme.of(context).colorScheme;
    final decoration = BoxDecoration(
      color: colorScheme.surface,
      border: Border(
        top: BorderSide(
          color: colorScheme.hintColor,
          width: 0.2,
        ),
      ),
    );

    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        ValueListenableBuilder(
          valueListenable: widget.controller.currentPost,
          builder: (_, post, _) => post.isVideo
              ? SliverToBoxAdapter(
                  child: DecoratedBox(
                    decoration: decoration,
                    child: PostDetailsVideoControls(
                      controller: widget.controller,
                    ),
                  ),
                )
              : const SliverSizedBox.shrink(),
        ),
        ValueListenableBuilder(
          valueListenable: widget.controller.currentPost,
          builder: (_, post, _) {
            final multiSliver = MultiSliver(
              children: preferredPreviewParts
                  .map((p) => uiBuilder.buildPart(context, p))
                  .nonNulls
                  .toList(),
            );

            return !post.isVideo
                ? DecoratedSliver(
                    decoration: decoration,
                    sliver: SliverPadding(
                      padding: const EdgeInsets.only(top: 8),
                      sliver: multiSliver,
                    ),
                  )
                : multiSliver;
          },
        ),
        const _SliverBottomPadding(),
      ],
    );
  }

  Widget _buildFallbackPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVideoControls(),
        SizedBox(
          height: MediaQuery.paddingOf(context).bottom,
        ),
      ],
    );
  }

  Widget _buildVideoControls() {
    return ValueListenableBuilder(
      valueListenable: widget.controller.currentPost,
      builder: (context, post, _) => post.isVideo
          ? PostDetailsVideoControls(
              controller: widget.controller,
            )
          : const SizedBox.shrink(),
    );
  }
}

class DisclaimerDialog extends StatelessWidget {
  const DisclaimerDialog({
    required this.disclaimer,
    super.key,
  });

  final String disclaimer;

  @override
  Widget build(BuildContext context) {
    final viewPadding = MediaQuery.paddingOf(context);

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 8),
          Text(
            disclaimer,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          SizedBox(
            height: viewPadding.bottom + 8,
          ),
        ],
      ),
    );
  }
}

class _SliverBottomPadding extends StatelessWidget {
  const _SliverBottomPadding();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedSliver(
      decoration: BoxDecoration(
        color: colorScheme.surface,
      ),
      sliver: SliverSizedBox(
        height: MediaQuery.paddingOf(context).bottom,
      ),
    );
  }
}
