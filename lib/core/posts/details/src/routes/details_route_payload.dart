// Package imports:
import 'package:equatable/equatable.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../post/post.dart';

class DetailsRoutePayload<T extends Post> extends Equatable {
  const DetailsRoutePayload({
    required this.initialIndex,
    required this.posts,
    required this.scrollController,
    required this.isDesktop,
  });

  DetailsRoutePayload<T> copyWith({
    int? initialIndex,
    AutoScrollController? scrollController,
    bool? isDesktop,
  }) {
    return DetailsRoutePayload<T>(
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
