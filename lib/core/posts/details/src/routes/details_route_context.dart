// Package imports:
import 'package:equatable/equatable.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../post/post.dart';

class DetailsRouteContext<T extends Post> extends Equatable {
  const DetailsRouteContext({
    required this.initialIndex,
    required this.posts,
    required this.scrollController,
    required this.isDesktop,
    required this.hero,
  });

  DetailsRouteContext<T> copyWith({
    int? initialIndex,
    AutoScrollController? scrollController,
    bool? isDesktop,
  }) {
    return DetailsRouteContext<T>(
      initialIndex: initialIndex ?? this.initialIndex,
      posts: posts,
      scrollController: scrollController ?? this.scrollController,
      isDesktop: isDesktop ?? this.isDesktop,
      hero: hero,
    );
  }

  final int initialIndex;
  final List<T> posts;
  final AutoScrollController? scrollController;
  final bool isDesktop;
  final bool hero;

  @override
  List<Object?> get props => [
        initialIndex,
        posts,
        scrollController,
        isDesktop,
        hero,
      ];
}
