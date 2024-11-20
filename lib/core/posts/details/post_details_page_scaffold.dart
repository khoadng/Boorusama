// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/notes/notes.dart';
import 'package:boorusama/core/posts/details/details.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

const String kShowInfoStateCacheKey = 'showInfoCacheStateKey';

class PostDetailsPageScaffold<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsPageScaffold({
    super.key,
    required this.posts,
    this.onExpanded,
    this.imageUrlBuilder,
    this.topRightButtonsBuilder,
    required this.controller,
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
  void dispose() {
    _controller.dispose();

    super.dispose();
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
        backgroundColor: context.colorScheme.secondaryContainer,
        child: _build(),
      ),
    );
  }

  Widget _build() {
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final imageUrlBuilder =
        widget.imageUrlBuilder ?? defaultPostImageUrlBuilder(ref);

    final uiBuilder = widget.uiBuilder ?? booruBuilder?.postDetailsUIBuilder;

    final settings = ref.watch(settingsProvider);

    return Scaffold(
      body: PostDetailsPageView(
        onPageChanged: (page) {
          widget.controller.setPage(page);

          ref
              .read(postShareProvider(posts[page]).notifier)
              .updateInformation(posts[page]);
        },
        sheetStateStorage: SheetStateStorageBuilder(
            save: (expanded) => ref
                .read(miscDataProvider(kShowInfoStateCacheKey).notifier)
                .put(expanded.toString()),
            load: () async =>
                ref.read(miscDataProvider(kShowInfoStateCacheKey)) == 'true'),
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
        onItemDoubleTap: booruBuilder?.canHandlePostGesture(
                      GestureType.doubleTap,
                      ref.watchConfig.postGestures?.fullview,
                    ) ==
                    true &&
                postGesturesHandler != null
            ? () => postGesturesHandler(
                  ref,
                  ref.watchConfig.postGestures?.fullview?.doubleTap,
                  posts[_controller.page],
                )
            : null,
        onItemLongPress: booruBuilder?.canHandlePostGesture(
                      GestureType.longPress,
                      ref.watchConfig.postGestures?.fullview,
                    ) ==
                    true &&
                postGesturesHandler != null
            ? () => postGesturesHandler(
                  ref,
                  ref.watchConfig.postGestures?.fullview?.longPress,
                  posts[_controller.page],
                )
            : null,
        onSwipeDownThresholdReached: booruBuilder?.canHandlePostGesture(
                      GestureType.swipeDown,
                      config.postGestures?.fullview,
                    ) ==
                    true &&
                postGesturesHandler != null
            ? () {
                _controller.resetSheet();

                postGesturesHandler(
                  ref,
                  config.postGestures?.fullview?.swipeDown,
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
                autoPlay: true,
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
                    builder: (_, state, __) => state.isExpanded
                        ? Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: VideoSoundScope(
                              builder: (context, soundOn) => SoundControlButton(
                                padding: const EdgeInsets.all(8),
                                soundOn: soundOn,
                                onSoundChanged: (value) =>
                                    ref.setGlobalVideoSound(value),
                              ),
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
    return ColoredBox(
      color: context.colorScheme.surface,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildVideoControls(),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final part in uiBuilder.preview.keys)
                uiBuilder.buildPart(context, part),
              SizedBox(
                height: MediaQuery.paddingOf(context).bottom,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFallbackPreview() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildVideoControls(),
      ],
    );
  }

  Widget _buildVideoControls() {
    return ValueListenableBuilder(
      valueListenable: widget.controller.currentPost,
      builder: (context, post, _) => post.isVideo
          ? ValueListenableBuilder(
              valueListenable: widget.controller.videoProgress,
              builder: (_, progress, __) => VideoSoundScope(
                builder: (context, soundOn) => BooruVideoProgressBar(
                  soundOn: soundOn,
                  progress: progress,
                  playbackSpeed: ref.watchPlaybackSpeed(post.videoUrl),
                  onSeek: (position) => widget.controller.onVideoSeekTo(
                    position,
                    post.id,
                    post.isWebm,
                  ),
                  onSpeedChanged: (speed) =>
                      ref.setPlaybackSpeed(post.videoUrl, speed),
                  onSoundToggle: (value) => ref.setGlobalVideoSound(value),
                ),
              ),
            )
          : const SizedBox.shrink(),
    );
  }
}

class PostDetailsFullInfoSheet extends ConsumerWidget {
  const PostDetailsFullInfoSheet({
    super.key,
    this.scrollController,
    this.uiBuilder,
    required this.sheetState,
  });

  final ScrollController? scrollController;
  final SheetState sheetState;
  final PostDetailsUIBuilder? uiBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watchBooruBuilder(ref.watchConfig);
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
      sliver: MultiSliver(
        children: [
          ...builder.full.keys.map((p) => builder.buildPart(context, p)),
        ],
      ),
      sheetState: sheetState,
    );
  }
}

class RawPostDetailsInfoSheet extends StatelessWidget {
  const RawPostDetailsInfoSheet({
    super.key,
    required this.scrollController,
    required this.preview,
    required this.sliver,
    required this.sheetState,
  });

  final ScrollController? scrollController;
  final Widget preview;
  final Widget sliver;

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
          const SliverSizedBox(height: 12),
          // SliverOffstage(
          //   offstage: sheetState == SheetState.hidden,
          //   sliver: sliver,
          // ),
          sliver,
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

    // // Pause previous video
    // if (posts[page].videoUrl.endsWith('.webm')) {
    //   _webmVideoControllers[page]?.pause();
    // } else {
    //   _videoControllers[page]?.pause();
    // }
  }

  void onCurrentPositionChanged(
      double current, double total, String url, int page) {
    // check if the current video is the same as the one being played
    if (posts[page].videoUrl != url) return;

    _videoProgress.value = VideoProgress(
        Duration(milliseconds: (total * 1000).toInt()),
        Duration(milliseconds: (current * 1000).toInt()));
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
