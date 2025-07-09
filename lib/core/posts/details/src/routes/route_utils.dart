// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../foundation/display.dart';
import '../../../../configs/config.dart';
import '../../../../router.dart';
import '../../../listing/providers.dart';
import '../../../post/post.dart';
import 'details_route_context.dart';

void goToPostDetailsPageFromPosts<T extends Post>({
  required WidgetRef ref,
  required List<T> posts,
  required int initialIndex,
  required String? initialThumbnailUrl,
  AutoScrollController? scrollController,
}) => goToPostDetailsPageCore(
  ref: ref,
  posts: posts,
  initialIndex: initialIndex,
  scrollController: scrollController,
  initialThumbnailUrl: initialThumbnailUrl,
  hero: false,
);

void goToPostDetailsPageFromController<T extends Post>({
  required WidgetRef ref,
  required int initialIndex,
  required PostGridController<T> controller,
  required String? initialThumbnailUrl,
  AutoScrollController? scrollController,
}) => goToPostDetailsPageCore(
  ref: ref,
  posts: controller.items.toList(),
  initialIndex: initialIndex,
  scrollController: scrollController,
  initialThumbnailUrl: initialThumbnailUrl,
  hero: true,
);

void goToPostDetailsPageCore<T extends Post>({
  required WidgetRef ref,
  required List<T> posts,
  required int initialIndex,
  required bool hero,
  required String? initialThumbnailUrl,
  AutoScrollController? scrollController,
}) {
  ref.router.push(
    Uri(
      path: '/details',
    ).toString(),
    extra: DetailsRouteContext(
      initialIndex: initialIndex,
      posts: posts,
      scrollController: scrollController,
      isDesktop: ref.context.isLargeScreen,
      hero: hero,
      initialThumbnailUrl: initialThumbnailUrl,
      configSearch: null,
    ),
  );
}

void goToSinglePostDetailsPage<T extends Post>({
  required WidgetRef ref,
  required PostId postId,
  required BooruConfigSearch configSearch,
}) {
  ref.router.push(
    Uri(
      path: '/posts/$postId',
    ).toString(),
    extra: DetailsRouteContext(
      initialIndex: 0,
      // ignore: prefer_const_literals_to_create_immutables
      posts: <T>[],
      scrollController: null,
      isDesktop: ref.context.isLargeScreen,
      hero: false,
      initialThumbnailUrl: null,
      configSearch: configSearch,
    ),
  );
}
