// Flutter imports:

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/settings/data.dart';
import '../../post/post.dart';
import 'inherited_post.dart';
import 'post_details.dart';
import 'post_details_controller.dart';

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

class CurrentPostScope<T extends Post> extends StatelessWidget {
  const CurrentPostScope({
    super.key,
    required this.post,
    required this.child,
  });

  final ValueNotifier<T> post;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: post,
      builder: (context, post, _) => InheritedPost<T>(
        post: post,
        child: child,
      ),
    );
  }
}
