// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:equatable/equatable.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../post/post.dart';
import 'post_details_controller.dart';

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
