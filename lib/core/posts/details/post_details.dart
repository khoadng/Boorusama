// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:video_player/video_player.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/videos/videos.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/widgets/widgets.dart';

class PostDetailsScope<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsScope({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.child,
    required this.scrollController,
  });

  final int initialIndex;
  final List<T> posts;
  final AutoScrollController? scrollController;
  final Widget child;

  @override
  ConsumerState<PostDetailsScope<T>> createState() =>
      _PostDetailsLayoutSwitcherState<T>();
}

class _PostDetailsLayoutSwitcherState<T extends Post>
    extends ConsumerState<PostDetailsScope<T>> {
  late PostDetailsController<T> controller = PostDetailsController<T>(
    scrollController: widget.scrollController,
    initialPage: widget.initialIndex,
    posts: widget.posts,
    reduceAnimations: ref.read(settingsProvider).reduceAnimations,
  );

  @override
  void dispose() {
    super.dispose();
    controller.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PostDetails(
      data: PostDetailsData(
        posts: widget.posts,
        controller: controller,
      ),
      child: CurrentPostScope(
        post: controller.currentPost,
        child: widget.child,
      ),
    );
  }
}

class PostDetailsData<T extends Post> {
  final List<T> posts;
  final PostDetailsController<T> controller;

  const PostDetailsData({
    required this.posts,
    required this.controller,
  });
}

class PostDetails<T extends Post> extends InheritedWidget {
  const PostDetails({
    super.key,
    required this.data,
    required super.child,
  });

  final PostDetailsData<T> data;

  static PostDetailsData<T> of<T extends Post>(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<PostDetails<T>>();
    return widget?.data ?? (throw Exception('No PostDetails found in context'));
  }

  static PostDetailsData<T>? maybeOf<T extends Post>(BuildContext context) {
    final widget = context.dependOnInheritedWidgetOfExactType<PostDetails<T>>();

    return widget?.data;
  }

  @override
  bool updateShouldNotify(PostDetails<T> oldWidget) {
    return data != oldWidget.data;
  }
}

class PostDetailsController<T extends Post> extends ChangeNotifier {
  PostDetailsController({
    required this.scrollController,
    required int initialPage,
    required this.posts,
    required this.reduceAnimations,
  })  : currentPage = ValueNotifier(initialPage),
        _initialPage = initialPage,
        currentPost = ValueNotifier(posts[initialPage]);
  final AutoScrollController? scrollController;
  final bool reduceAnimations;
  final List<T> posts;
  final int _initialPage;

  late ValueNotifier<int> currentPage;
  late ValueNotifier<T> currentPost;

  int get initialPage =>
      currentPage.value != _initialPage ? currentPage.value : _initialPage;

  void setPage(int page) {
    currentPage.value = page;
    _videoProgress.value = VideoProgress.zero;

    final post = posts.getOrNull(page);

    if (post != null) {
      currentPost.value = post;
    }
  }

  void onExit() {
    // https://github.com/quire-io/scroll-to-index/issues/44
    // skip scrolling if reduceAnimations is enabled due to a limitation in the package
    if (reduceAnimations) return;

    final page = currentPage.value;

    scrollController?.scrollToIndex(page);
  }

  final _videoProgress = ValueNotifier(VideoProgress.zero);

  //TODO: should have an abstraction for this crap, but I'm too lazy to do it since there are only 2 types of video anyway
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, WebmVideoController> _webmVideoControllers = {};

  ValueNotifier<VideoProgress> get videoProgress => _videoProgress;

  void onCurrentPositionChanged(double current, double total, String url) {
    // // check if the current video is the same as the one being played
    if (posts[currentPage.value].videoUrl != url) return;

    _videoProgress.value = VideoProgress(
        Duration(milliseconds: (total * 1000).toInt()),
        Duration(milliseconds: (current * 1000).toInt()));
  }

  void onVideoSeekTo(Duration position, int id, bool isWebm) {
    // Only Android is using Webview for webm
    if (isWebm && isAndroid()) {
      _webmVideoControllers[id]?.seek(position.inSeconds.toDouble());
    } else {
      _videoControllers[id]?.seekTo(position);
    }
  }

  void onWebmVideoPlayerCreated(WebmVideoController controller, int id) {
    _webmVideoControllers[id] = controller;
  }

  void onVideoPlayerCreated(VideoPlayerController controller, int id) {
    _videoControllers[id] = controller;
  }
}

class DetailsPayload<T extends Post> extends Equatable {
  const DetailsPayload({
    required this.initialIndex,
    required this.posts,
    required this.scrollController,
    required this.isDesktop,
  });

  DetailsPayload<T> copyWith({
    int? initialIndex,
    AutoScrollController? scrollController,
    bool? isDesktop,
  }) {
    return DetailsPayload<T>(
      initialIndex: initialIndex ?? this.initialIndex,
      posts: posts,
      scrollController: scrollController ?? this.scrollController,
      isDesktop: isDesktop ?? this.isDesktop,
    );
  }

  final int initialIndex;
  final List<T> posts;
  final AutoScrollController? scrollController;
  final bool isDesktop;

  @override
  List<Object?> get props => [
        initialIndex,
        posts,
        scrollController,
        isDesktop,
      ];
}