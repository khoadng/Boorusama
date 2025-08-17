// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../details_pageview/widgets.dart';

class PostDetailsPageViewScope extends InheritedWidget {
  const PostDetailsPageViewScope({
    required this.controller,
    required super.child,
    super.key,
  });

  final PostDetailsPageViewController controller;

  static PostDetailsPageViewController of(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<PostDetailsPageViewScope>();
    return widget?.controller ??
        (throw Exception('No PostDetailsPageViewScope found in context'));
  }

  static PostDetailsPageViewController? maybeOf(BuildContext context) {
    final widget = context
        .dependOnInheritedWidgetOfExactType<PostDetailsPageViewScope>();
    return widget?.controller;
  }

  @override
  bool updateShouldNotify(PostDetailsPageViewScope oldWidget) {
    return controller != oldWidget.controller;
  }
}
