// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project imports:
import '../../../../boorus/engine/engine.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../cache/providers.dart';
import '../../../../configs/config.dart';
import '../../../../configs/ref.dart';
import '../../../../foundation/display.dart';
import '../../../../notes/notes.dart';
import '../../../../router.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../videos/play_pause_button.dart';
import '../../../../videos/providers.dart';
import '../../../../videos/sound_control_button.dart';
import '../../../../videos/video_progress.dart';
import '../../../../widgets/widgets.dart';
import '../../../post/post.dart';
import '../../../post/routes.dart';
import '../../../shares/providers.dart';
import 'post_details_controller.dart';
import 'post_details_page_view.dart';
import 'post_details_preload_image.dart';
import 'post_media.dart';
import 'video_controls.dart';

const String kShowInfoStateCacheKey = 'showInfoCacheStateKey';

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    required this.posts,
    required this.controller,
    super.key,
    this.onExpanded,
    this.imageUrlBuilder,
    this.topRightButtonsBuilder,
    this.uiBuilder,
  });

  final List<T> posts;
  final void Function()? onExpanded;
  final String Function(T post)? imageUrlBuilder;
  final List<Widget> Function(PostDetailsPageViewController controller)?
      topRightButtonsBuilder;
  final PostDetailsController<T> controller;
  final PostDetailsUIBuilder? uiBuilder;

  @override
  ConsumerState<PostDetailsPageScaffold<T>> createState() =>
      _PostDetailPageScaffoldState<T>();
}

class _PostDetailPageScaffoldState<T extends Post>
    extends ConsumerState<PostDetailsPageScaffold<T>> {
  late final _posts = widget.posts;
  late final _controller = PostDetailsPageViewController(
    initialPage: widget.controller.initialPage,
    hideOverlay: ref.read(settingsProvider).hidePostDetailsOverlay,
  );

  List<T> get posts => _posts;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      final settings = ref.read(settingsProvider);
      widget.controller.setPage(
        widget.controller.initialPage,
        useDefaultEngine: _isDefaultEngine(settings),
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  var _previouslyPlaying = false;

  bool _isDefaultEngine(Settings settings) {
    return settings.videoPlayerEngine != VideoPlayerEngine.mdk;
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(
      settingsProvider.select((value) => value.hidePostDetailsOverlay),
      (previous, next) {
        if (previous != next && _controller.overlay.value != next) {
          _controller.overlay.value = !next;
        }
      },
    );

    final useDefaultEngine = ref.watch(
      settingsProvider.select(
        (value) => _isDefaultEngine(value),
      ),
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
              _previouslyPlaying = widget.controller.isVideoPlaying.value;
              if (_previouslyPlaying) {
                widget.controller.pauseCurrentVideo(
                  useDefaultEngine: useDefaultEngine,
                );
              }
            } else if (info.visibleFraction == 1) {
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
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = ref.watchPostGestures?.fullview;
    final imageUrlBuilder =
        widget.imageUrlBuilder ?? defaultPostImageUrlBuilder(ref);

    final uiBuilder = widget.uiBuilder ?? booruBuilder?.postDetailsUIBuilder;

    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: PostDetailsPageView(
        onPageChanged: (page) {
          widget.controller.setPage(
            page,
            useDefaultEngine: _isDefaultEngine(settings),
          );

          ref
              .read(postShareProvider(posts[page]).notifier)
              .updateInformation(posts[page]);
        },
        sheetStateStorage: SheetStateStorageBuilder(
          save: (expanded) => ref
              .read(miscDataProvider(kShowInfoStateCacheKey).notifier)
              .put(expanded.toString()),
          load: () async =>
              ref.read(miscDataProvider(kShowInfoStateCacheKey)) == 'true',
        ),
        slideshowOptions: SlideshowOptions(
          duration: settings.slideshowDuration,
          direction: settings.slideshowDirection,
          skipTransition: settings.skipSlideshowTransition,
        ),
        controller: _controller,
        onExit: widget.controller.onExit,
        itemCount: posts.length,
        leftActions: [
          CircularIconButton(
            icon: const Icon(
              Symbols.home,
              fill: 1,
            ),
            onPressed: () => goToHomePage(context),
          ),
        ],
        onItemDoubleTap: gestures.canDoubleTap && postGesturesHandler != null
            ? () => postGesturesHandler(
                  ref,
                  gestures?.doubleTap,
                  posts[_controller.page],
                )
            : null,
        onItemLongPress: gestures.canLongPress && postGesturesHandler != null
            ? () => postGesturesHandler(
                  ref,
                  gestures?.longPress,
                  posts[_controller.page],
                )
            : null,
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
          return ValueListenableBuilder(
            valueListenable: _controller.sheetState,
            builder: (context, state, _) => PostDetailsFullInfoSheet(
              scrollController: scrollController,
              sheetState: state,
              uiBuilder: uiBuilder,
            ),
          );
        },
        itemBuilder: (context, index) {
          final post = posts[index];
          final (previousPost, nextPost) = posts.getPrevAndNextPosts(index);

          return Stack(
            alignment: Alignment.center,
            children: [
              // preload next image only, not the post itself
              if (nextPost != null && !nextPost.isVideo)
                Offstage(
                  child: PostDetailsPreloadImage(
                    url: imageUrlBuilder(nextPost),
                  ),
                ),
              PostMedia<T>(
                post: post,
                imageUrl: imageUrlBuilder(post),
                imageOverlayBuilder: (constraints) =>
                    noteOverlayBuilderDelegate(
                  constraints,
                  post,
                  ref.watch(notesControllerProvider(post)),
                ),
                controller: _controller,
              ),
              if (previousPost != null && !previousPost.isVideo)
                Offstage(
                  child: PostDetailsPreloadImage(
                    url: imageUrlBuilder(previousPost),
                  ),
                ),
              if (post.isVideo)
                Align(
                  alignment: Alignment.bottomRight,
                  child: ValueListenableBuilder(
                    valueListenable: _controller.sheetState,
                    builder: (_, state, __) => state.isExpanded &&
                            !context.isLargeScreen
                        ? Padding(
                            padding: const EdgeInsets.all(8),
                            child: Row(
                              children: [
                                // duplicate codes, maybe refactor later
                                PlayPauseButton(
                                  isPlaying: widget.controller.isVideoPlaying,
                                  onPlayingChanged: (value) {
                                    if (value) {
                                      widget.controller.pauseVideo(
                                        post.id,
                                        post.isWebm,
                                        _isDefaultEngine(settings),
                                      );
                                    } else if (!value) {
                                      widget.controller.playVideo(
                                        post.id,
                                        post.isWebm,
                                        _isDefaultEngine(settings),
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
                ),
            ],
          );
        },
        bottomSheet: widget.uiBuilder != null
            ? _buildCustomPreview(widget.uiBuilder!)
            : uiBuilder != null && uiBuilder.preview.isNotEmpty
                ? _buildCustomPreview(uiBuilder)
                : _buildFallbackPreview(),
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
                noteState: ref.watch(notesControllerProvider(post)),
              ),
            ),
            const SizedBox(width: 8),
            ValueListenableBuilder(
              valueListenable: widget.controller.currentPost,
              builder: (context, post, _) => GeneralMoreActionButton(
                post: post,
                onStartSlideshow: () => _controller.startSlideshow(),
              ),
            ),
          ],
        ],
        onExpanded: widget.onExpanded,
      ),
    );
  }

  Widget _buildCustomPreview(PostDetailsUIBuilder uiBuilder) {
    return CustomScrollView(
      shrinkWrap: true,
      slivers: [
        SliverToBoxAdapter(
          child: _buildVideoControls(),
        ),
        DecoratedSliver(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          sliver: MultiSliver(
            children: uiBuilder.preview.keys
                .map((p) => uiBuilder.buildPart(context, p))
                .nonNulls
                .toList(),
          ),
        ),
        DecoratedSliver(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
          ),
          sliver: SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom,
          ),
        ),
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

class PostDetailsFullInfoSheet extends ConsumerWidget {
  const PostDetailsFullInfoSheet({
    required this.sheetState,
    super.key,
    this.scrollController,
    this.uiBuilder,
  });

  final ScrollController? scrollController;
  final SheetState sheetState;
  final PostDetailsUIBuilder? uiBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final builder = uiBuilder ?? booruBuilder?.postDetailsUIBuilder;

    if (builder == null) {
      return DefaultPostDetailsInfoPreview(
        scrollController: scrollController,
      );
    }

    return RawPostDetailsInfoSheet(
      scrollController: scrollController,
      preview: DefaultPostDetailsInfoPreview(
        scrollController: scrollController,
      ),
      slivers: builder.full.keys
          .map((p) => builder.buildPart(context, p))
          .nonNulls
          .toList(),
      sheetState: sheetState,
    );
  }
}

class RawPostDetailsInfoSheet extends StatelessWidget {
  const RawPostDetailsInfoSheet({
    required this.scrollController,
    required this.preview,
    required this.slivers,
    required this.sheetState,
    super.key,
  });

  final ScrollController? scrollController;
  final Widget preview;
  final List<Widget> slivers;

  final SheetState sheetState;

  @override
  Widget build(BuildContext context) {
    if (sheetState == SheetState.collapsed) {
      return preview;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          const SliverSizedBox(height: 24),
          ...slivers,
          SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom + 72,
          ),
        ],
      ),
    );
  }
}

class DefaultPostDetailsInfoPreview extends StatelessWidget {
  const DefaultPostDetailsInfoPreview({
    super.key,
    this.scrollController,
  });

  final ScrollController? scrollController;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: CustomScrollView(
        controller: scrollController,
        slivers: [
          const SliverSizedBox(height: 12),
          SliverSizedBox(
            height: MediaQuery.paddingOf(context).bottom + 72,
          ),
        ],
      ),
    );
  }
}

mixin PostDetailsPageMixin<T extends StatefulWidget, E extends Post>
    on State<T> {
  final _videoProgress = ValueNotifier(VideoProgress.zero);

  //TODO: should have an abstraction for this crap, but I'm too lazy to do it since there are only 2 types of video anyway
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, WebmVideoController> _webmVideoControllers = {};

  List<E> get posts;
  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;

  void onPageChanged(int page) {
    _videoProgress.value = VideoProgress.zero;
  }

  void onCurrentPositionChanged(
    double current,
    double total,
    String url,
    int page,
  ) {
    // check if the current video is the same as the one being played
    if (posts[page].videoUrl != url) return;

    _videoProgress.value = VideoProgress(
      Duration(milliseconds: (total * 1000).toInt()),
      Duration(milliseconds: (current * 1000).toInt()),
    );
  }

  void onVideoSeekTo(Duration position, int page) {
    if (posts[page].videoUrl.endsWith('.webm')) {
      _webmVideoControllers[page]?.seek(position.inSeconds.toDouble());
    } else {
      _videoControllers[page]?.seekTo(position);
    }
  }

  void onWebmVideoPlayerCreated(WebmVideoController controller, int page) {
    _webmVideoControllers[page] = controller;
  }

  void onVideoPlayerCreated(VideoPlayerController controller, int page) {
    _videoControllers[page] = controller;
  }
}

extension PostDetailsUtils<T extends Post> on List<T> {
  (T? prev, T? next) getPrevAndNextPosts(int index) {
    final next = index + 1 < length ? this[index + 1] : null;
    final prev = index - 1 >= 0 ? this[index - 1] : null;

    return (prev, next);
  }
}
