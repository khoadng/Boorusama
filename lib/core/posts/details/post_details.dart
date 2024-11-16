// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/widgets/widgets.dart';

class FlexibleLayoutSwitcher extends StatelessWidget {
  const FlexibleLayoutSwitcher({
    super.key,
    required this.desktop,
    required this.mobile,
  });

  final Widget Function() desktop;
  final Widget Function() mobile;

  @override
  Widget build(BuildContext context) {
    return kPreferredLayout.isMobile
        ? PerformanceOrientationBuilder(
            builder: (context, orientation) =>
                orientation == Orientation.portrait ? mobile() : desktop(),
          )
        : desktop();
  }
}

class PostDetailsLayoutSwitcher<T extends Post> extends ConsumerStatefulWidget {
  const PostDetailsLayoutSwitcher({
    super.key,
    required this.initialIndex,
    required this.posts,
    required this.desktop,
    required this.mobile,
    required this.scrollController,
  });

  final int initialIndex;
  final List<T> posts;
  final AutoScrollController? scrollController;
  final Widget Function()? desktop;
  final Widget Function() mobile;

  @override
  ConsumerState<PostDetailsLayoutSwitcher<T>> createState() =>
      _PostDetailsLayoutSwitcherState<T>();
}

class _PostDetailsLayoutSwitcherState<T extends Post>
    extends ConsumerState<PostDetailsLayoutSwitcher<T>> {
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
        child: FlexibleLayoutSwitcher(
          desktop: () =>
              widget.desktop != null ? widget.desktop!() : widget.mobile(),
          mobile: () => widget.mobile(),
        ),
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
}
