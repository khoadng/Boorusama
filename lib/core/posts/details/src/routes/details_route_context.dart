// Package imports:
import 'package:equatable/equatable.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../post/post.dart';

class DetailsRouteContext<T extends Post> extends Equatable {
  const DetailsRouteContext({
    required this.initialIndex,
    required this.posts,
    required this.scrollController,
    required this.isDesktop,
    required this.hero,
    required this.initialThumbnailUrl,
    required this.configSearch,
    this.dislclaimer,
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
      initialThumbnailUrl: initialThumbnailUrl,
      dislclaimer: dislclaimer,
      configSearch: configSearch,
    );
  }

  final int initialIndex;
  final List<T> posts;
  final AutoScrollController? scrollController;
  final bool isDesktop;
  final bool hero;
  final String? initialThumbnailUrl;
  final String? dislclaimer;
  final BooruConfigSearch? configSearch;

  @override
  List<Object?> get props => [
    initialIndex,
    posts,
    scrollController,
    isDesktop,
    hero,
    initialThumbnailUrl,
    dislclaimer,
  ];
}
