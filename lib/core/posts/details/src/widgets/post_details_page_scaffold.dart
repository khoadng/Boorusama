// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project imports:
import '../../../../analytics.dart';
import '../../../../boorus/engine/engine.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../cache/providers.dart';
import '../../../../configs/config.dart';
import '../../../../configs/current.dart';
import '../../../../foundation/display.dart';
import '../../../../foundation/platform.dart';
import '../../../../notes/notes.dart';
import '../../../../premiums/providers.dart';
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../theme/app_theme.dart';
import '../../../../videos/play_pause_button.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/sound_control_button.dart';
import '../../../../videos/video_progress.dart';
import '../../../../widgets/widgets.dart';
import '../../../details_manager/types.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../../../post/routes.dart';
import '../../../shares/providers.dart';
import 'post_details_controller.dart';
import 'post_details_full_info_sheet.dart';
import 'post_details_preload_image.dart';
import 'post_media.dart';
import 'video_controls.dart';
import 'volume_key_page_navigator.dart';

const String kShowInfoStateCacheKey = 'showInfoCacheStateKey';

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    required this.posts,
    required this.controller,
    required this.viewerConfig,
    required this.authConfig,
    required this.gestureConfig,
    super.key,
    this.onExpanded,
    this.imageUrlBuilder,
    this.topRightButtonsBuilder,
    this.uiBuilder,
    this.preferredParts,
    this.preferredPreviewParts,
    this.imageCacheManager,
  });

  final List<T> posts;
  final void Function()? onExpanded;
  final String Function(T post)? imageUrlBuilder;
  final ImageCacheManager Function(Post post)? imageCacheManager;
  final List<Widget> Function(PostDetailsPageViewController controller)?
      topRightButtonsBuilder;
  final PostDetailsController<T> controller;
  final PostDetailsUIBuilder? uiBuilder;
  final Set<DetailsPart>? preferredParts;
  final Set<DetailsPart>? preferredPreviewParts;
  final BooruConfigViewer viewerConfig;
  final BooruConfigAuth authConfig;
  final PostGestureConfig? gestureConfig;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>> {
  late final _posts = widget.posts;
  late final _controller = PostDetailsPageViewController(
    initialPage: widget.controller.initialPage,
    initialHideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
    slideshowOptions: toSlideShowOptions(ref.read(settingsProvider)),
    hoverToControlOverlay: widget.posts[widget.controller.initialPage].isVideo,
    checkIfLargeScreen: () => context.isLargeScreen,
    totalPage: _posts.length,
    disableAnimation:
        ref.read(settingsProvider.select((value) => value.reduceAnimations)),
  );
  late final _volumeKeyPageNavigator = VolumeKeyPageNavigator(
    pageViewController: _controller,
    totalPosts: _posts.length,
    visibilityNotifier: visibilityNotifier,
    enableVolumeKeyViewerNavigation: () => ref.read(
      settingsProvider.select((value) => value.volumeKeyViewerNavigation),
    ),
  );

  final _transformController = TransformationController();

  ValueNotifier<bool> visibilityNotifier = ValueNotifier(false);
  final _isInitPage = ValueNotifier(true);

  Timer? _autoHideVideoControlsTimer;
  bool _videoControlsHiddenByTimer = false;
  StreamSubscription<VideoProgress>? _seekStreamSubscription;

  List<T> get posts => _posts;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final videoPlayerEngine =
          ref.read(settingsProvider.select((value) => value.videoPlayerEngine));

      widget.controller.setPage(
        widget.controller.initialPage,
        useDefaultEngine: _isDefaultEngine(videoPlayerEngine),
      );

      if (widget.viewerConfig.autoFetchNotes) {
        ref.read(notesProvider(widget.authConfig).notifier).load(
              posts[widget.controller.initialPage],
            );
      }

      if (posts[widget.controller.initialPage].isVideo) {
        _startAutoHideVideoControlsTimer();
      }
    });

    widget.controller.isVideoPlaying.addListener(_isVideoPlayingChanged);
    _seekStreamSubscription = widget.controller.seekStream.listen(
      (event) {
        // cancel the timer when user is seeking
        _clearAutoHideVideoControlsTimer();
      },
    );

    _volumeKeyPageNavigator.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    _transformController.dispose();
    _volumeKeyPageNavigator.dispose();
    widget.controller.isVideoPlaying.removeListener(_isVideoPlayingChanged);
    _autoHideVideoControlsTimer?.cancel();
    _autoHideVideoControlsTimer = null;
    _seekStreamSubscription?.cancel();

    super.dispose();
  }

  var _previouslyPlaying = false;

  bool _isDefaultEngine(VideoPlayerEngine engine) {
    return engine != VideoPlayerEngine.mdk;
  }

  void _startAutoHideVideoControlsTimer() {
    final hideOverlay = ref.read(settingsProvider).hidePostDetailsOverlay;

    if (hideOverlay) return;

    _clearAutoHideVideoControlsTimer();

    _autoHideVideoControlsTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        _controller.hideAllUI();

        _videoControlsHiddenByTimer = true;
      }
    });
  }

  void _clearAutoHideVideoControlsTimer() {
    _autoHideVideoControlsTimer?.cancel();
    _autoHideVideoControlsTimer = null;

    // if the video controls are hidden by the timer, show them again
    if (_videoControlsHiddenByTimer) {
      _controller.showAllUI();
    }

    _videoControlsHiddenByTimer = false;
  }

  SlideshowOptions toSlideShowOptions(Settings settings) {
    return SlideshowOptions(
      duration: settings.slideshowDuration,
      direction: settings.slideshowDirection,
      skipTransition: settings.skipSlideshowTransition,
    );
  }

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
        (value) => _isDefaultEngine(value.videoPlayerEngine),
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
              context,
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
    final booruBuilder = ref.watch(booruBuilderProvider(widget.authConfig));
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = widget.gestureConfig?.fullview;

    final imageUrlBuilder = widget.imageUrlBuilder ??
        defaultPostImageUrlBuilder(ref, widget.authConfig, widget.viewerConfig);

    final uiBuilder = widget.uiBuilder ?? booruBuilder?.postDetailsUIBuilder;

    final videoPlayerEngine =
        ref.watch(settingsProvider.select((value) => value.videoPlayerEngine));
    final reduceAnimations =
        ref.watch(settingsProvider.select((value) => value.reduceAnimations));

    void onItemTap() {
      final controller = widget.controller;

      if (isDesktopPlatform()) {
        if (controller.currentPost.value.isVideo) {
          if (controller.isVideoPlaying.value) {
            controller.pauseCurrentVideo(
              useDefaultEngine: _isDefaultEngine(videoPlayerEngine),
            );
          } else {
            controller.playCurrentVideo(
              useDefaultEngine: _isDefaultEngine(videoPlayerEngine),
            );
          }
        } else {
          if (_controller.isExpanded) return;

          _controller.toggleOverlay();
        }
      } else {
        if (_controller.isExpanded) return;

        _controller.toggleOverlay();
      }
    }

    return Scaffold(
      body: PostDetailsPageView(
        disableAnimation: reduceAnimations,
        onPageChanged: (page) {
          final post = posts[page];

          widget.controller.setPage(
            page,
            useDefaultEngine: _isDefaultEngine(videoPlayerEngine),
          );

          _isInitPage.value = false;

          if (_controller.overlay.value) {
            if (post.isVideo) {
              _controller.enableHoverToControlOverlay();
            } else {
              _controller.disableHoverToControlOverlay();
            }
          }

          if (post.isVideo) {
            _startAutoHideVideoControlsTimer();
          } else {
            _clearAutoHideVideoControlsTimer();
          }

          ref.read(postShareProvider(post).notifier).updateInformation(post);

          if (widget.viewerConfig.autoFetchNotes) {
            ref.read(notesProvider(widget.authConfig).notifier).load(post);
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
          ref.invalidate(notesProvider(widget.authConfig));

          widget.controller.onExit();
        },
        itemCount: posts.length,
        leftActions: [
          CircularIconButton(
            icon: const Icon(
              Symbols.home,
              fill: 1,
            ),
            onPressed: () => goToHomePage(context),
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
            builder: (_, ref, __) {
              final layoutDetails = ref.watch(
                currentReadOnlyBooruConfigLayoutProvider
                    .select((value) => value?.details),
              );
              final preferredParts = widget.preferredParts ??
                  getLayoutParsedParts(
                    details: layoutDetails,
                    hasPremium: ref.watch(hasPremiumProvider),
                  ) ??
                  uiBuilder?.full.keys.toSet();

              return ValueListenableBuilder(
                valueListenable: _controller.sheetState,
                builder: (context, state, _) => PostDetailsFullInfoSheet(
                  scrollController: scrollController,
                  sheetState: state,
                  uiBuilder: uiBuilder,
                  preferredParts: preferredParts,
                  canCustomize: kPremiumEnabled && widget.uiBuilder == null,
                ),
              );
            },
          );
        },
        itemBuilder: (context, index) {
          final post = posts[index];
          final (previousPost, nextPost) = posts.getPrevAndNextPosts(index);

          return ValueListenableBuilder(
            valueListenable: _controller.sheetState,
            builder: (_, state, __) => GestureDetector(
              // let the user tap the image to toggle overlay
              onTap: onItemTap,
              child: InteractiveViewerExtended(
                contentSize: Size(post.width, post.height),
                controller: _transformController,
                enable: switch (state.isExpanded) {
                  true => context.isLargeScreen,
                  false => true,
                },
                onZoomUpdated: _controller.onZoomUpdated,
                onTap: onItemTap,
                onDoubleTap:
                    gestures.canDoubleTap && postGesturesHandler != null
                        ? () => postGesturesHandler(
                              ref,
                              gestures?.doubleTap,
                              posts[_controller.page],
                            )
                        : null,
                onLongPress:
                    gestures.canLongPress && postGesturesHandler != null
                        ? () => postGesturesHandler(
                              ref,
                              gestures?.longPress,
                              posts[_controller.page],
                            )
                        : null,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // preload next image only, not the post itself
                    if (nextPost != null && !nextPost.isVideo)
                      Offstage(
                        child: PostDetailsPreloadImage(
                          post: nextPost,
                          url: imageUrlBuilder(nextPost),
                        ),
                      ),
                    ValueListenableBuilder(
                      valueListenable: _isInitPage,
                      builder: (_, isInitPage, __) {
                        final initialThumbnailUrl =
                            widget.controller.initialThumbnailUrl;

                        return PostMedia<T>(
                          post: post,
                          imageUrlBuilder: imageUrlBuilder,
                          imageCacheManager: widget.imageCacheManager,
                          // This is used to make sure we have a thumbnail to show instead of a black placeholder
                          thumbnailUrlBuilder: isInitPage &&
                                  initialThumbnailUrl != null
                              // Need to specify the type here to avoid type inference error
                              // ignore: avoid_types_on_closure_parameters
                              ? (Post _) => initialThumbnailUrl
                              : null,
                          controller: _controller,
                        );
                      },
                    ),
                    if (previousPost != null && !previousPost.isVideo)
                      Offstage(
                        child: PostDetailsPreloadImage(
                          post: previousPost,
                          url: imageUrlBuilder(previousPost),
                        ),
                      ),
                    if (post.isVideo)
                      Align(
                        alignment: Alignment.bottomRight,
                        child: state.isExpanded && !context.isLargeScreen
                            ? Padding(
                                padding: const EdgeInsets.all(8),
                                child: Row(
                                  children: [
                                    // duplicate codes, maybe refactor later
                                    PlayPauseButton(
                                      isPlaying:
                                          widget.controller.isVideoPlaying,
                                      onPlayingChanged: (value) {
                                        if (value) {
                                          widget.controller.pauseVideo(
                                            post.id,
                                            post.isWebm,
                                            _isDefaultEngine(videoPlayerEngine),
                                          );
                                        } else if (!value) {
                                          widget.controller.playVideo(
                                            post.id,
                                            post.isWebm,
                                            _isDefaultEngine(videoPlayerEngine),
                                          );
                                        } else {
                                          // do nothing
                                        }
                                      },
                                    ),
                                    VideoSoundScope(
                                      builder: (context, soundOn) =>
                                          SoundControlButton(
                                        padding: const EdgeInsets.all(8),
                                        soundOn: soundOn,
                                        onSoundChanged: (value) =>
                                            ref.setGlobalVideoSound(value),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : const SizedBox.shrink(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
        bottomSheet: Consumer(
          builder: (_, ref, __) {
            final layoutPreviewDetails = ref.watch(
              currentReadOnlyBooruConfigLayoutProvider
                  .select((value) => value?.previewDetails),
            );

            return widget.uiBuilder != null
                ? _buildCustomPreview(widget.uiBuilder!, layoutPreviewDetails)
                : uiBuilder != null && uiBuilder.preview.isNotEmpty
                    ? _buildCustomPreview(uiBuilder, layoutPreviewDetails)
                    : _buildFallbackPreview();
          },
        ),
        actions: [
          if (widget.topRightButtonsBuilder != null)
            ...widget.topRightButtonsBuilder!(
              _controller,
            )
          else ...[
            ValueListenableBuilder(
              valueListenable: widget.controller.currentPost,
              builder: (context, post, _) => NoteActionButtonWithProvider(
                post: post,
                config: widget.authConfig,
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder(
              valueListenable: widget.controller.currentPost,
              builder: (context, post, _) => GeneralMoreActionButton(
                post: post,
                config: widget.authConfig,
                onStartSlideshow: () => _controller.startSlideshow(),
              ),
            ),
          ],
        ],
        onExpanded: () {
          widget.onExpanded?.call();
          // Reset zoom when expanded
          _transformController.value = Matrix4.identity();
          ref.read(analyticsProvider).whenData(
                (analytics) => analytics.logScreenView('/details/info'),
              );
        },
        onShrink: () {
          final routeName = ModalRoute.of(context)?.settings.name;
          if (routeName != null) {
            ref.read(analyticsProvider).whenData(
                  (analytics) => analytics.logScreenView(routeName),
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
    final preferredPreviewParts = widget.preferredPreviewParts ??
        getLayoutPreviewParsedParts(
          previewDetails: layoutPreviewDetails,
          hasPremium: ref.watch(hasPremiumProvider),
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
          builder: (_, post, __) => post.isVideo
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
          builder: (_, post, __) {
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

extension PostDetailsUtils<T extends Post> on List<T> {
  (T? prev, T? next) getPrevAndNextPosts(int index) {
    final next = index + 1 < length ? this[index + 1] : null;
    final prev = index - 1 >= 0 ? this[index - 1] : null;

    return (prev, next);
  }
}
