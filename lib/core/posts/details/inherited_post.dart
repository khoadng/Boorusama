// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../posts.dart';

class InheritedPost<T extends Post> extends InheritedWidget {
  const InheritedPost({
    super.key,
    required this.post,
    required super.child,
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
