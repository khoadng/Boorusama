// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../settings/settings.dart';
import '../../../details_pageview/widgets.dart';
import '../../../post/post.dart';
import '../widgets/post_details_controller.dart';

class PostDetailsData<T extends Post> {
  const PostDetailsData({
    required this.posts,
    required this.controller,
  });

  final List<T> posts;
  final PostDetailsController<T> controller;
}

class PostDetails<T extends Post> extends InheritedWidget {
  const PostDetails({
    required this.data,
    required super.child,
    super.key,
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

SlideshowOptions toSlideShowOptions(Settings settings) {
  return SlideshowOptions(
    duration: settings.slideshowDuration,
    direction: settings.slideshowDirection,
    skipTransition: settings.skipSlideshowTransition,
  );
}
