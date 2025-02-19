// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../post/post.dart';

class InheritedPost<T extends Post> extends InheritedWidget {
  const InheritedPost({
    required this.post,
    required super.child,
    super.key,
  });

  final T post;

  static T of<T extends Post>(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<InheritedPost<T>>();
    return widget?.post ??
        (throw Exception('No InheritedPost found in context'));
  }

  static T? maybeOf<T extends Post>(BuildContext context) {
    final widget =
        context.dependOnInheritedWidgetOfExactType<InheritedPost<T>>();

    return widget?.post;
  }

  @override
  bool updateShouldNotify(InheritedPost<T> oldWidget) {
    return post != oldWidget.post;
  }
}
