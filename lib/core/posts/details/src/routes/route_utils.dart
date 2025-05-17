// Flutter imports:
import 'package:flutter/cupertino.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../configs/config.dart';
import '../../../../foundation/display.dart';
import '../../../../router.dart';
import '../../../listing/providers.dart';
import '../../../post/post.dart';
import 'details_route_context.dart';

void goToPostDetailsPageFromPosts<T extends Post>({
  required BuildContext context,
  required List<T> posts,
  required int initialIndex,
  required String? initialThumbnailUrl,
  AutoScrollController? scrollController,
}) =>
    goToPostDetailsPageCore(
      context: context,
      posts: posts,
      initialIndex: initialIndex,
      scrollController: scrollController,
      initialThumbnailUrl: initialThumbnailUrl,
      hero: false,
    );

void goToPostDetailsPageFromController<T extends Post>({
  required BuildContext context,
  required int initialIndex,
  required PostGridController<T> controller,
  required String? initialThumbnailUrl,
  AutoScrollController? scrollController,
}) =>
    goToPostDetailsPageCore(
      context: context,
      posts: controller.items.toList(),
      initialIndex: initialIndex,
      scrollController: scrollController,
      initialThumbnailUrl: initialThumbnailUrl,
      hero: true,
    );

void goToPostDetailsPageCore<T extends Post>({
  required BuildContext context,
  required List<T> posts,
  required int initialIndex,
  required bool hero,
  required String? initialThumbnailUrl,
  AutoScrollController? scrollController,
}) {
  context.push(
    Uri(
      path: '/details',
    ).toString(),
    extra: DetailsRouteContext(
      initialIndex: initialIndex,
      posts: posts,
      scrollController: scrollController,
      isDesktop: context.isLargeScreen,
      hero: hero,
      initialThumbnailUrl: initialThumbnailUrl,
    ),
  );
}

void goToSinglePostDetailsPage<T extends Post>({
  required BuildContext context,
  required PostId postId,
  required BooruConfigSearch configSearch,
}) {
  context.push(
    Uri(
      path: '/posts/$postId',
    ).toString(),
  );
}
