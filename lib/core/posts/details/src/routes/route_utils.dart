// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../foundation/display.dart';
import '../../../../router.dart';
import '../../../listing/providers.dart';
import '../../../post/post.dart';
import 'details_route_payload.dart';

void goToPostDetailsPageFromPosts<T extends Post>({
  required BuildContext context,
  required List<T> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) =>
    goToPostDetailsPageCore(
      context: context,
      posts: posts,
      initialIndex: initialIndex,
      scrollController: scrollController,
    );

void goToPostDetailsPageFromController<T extends Post>({
  required BuildContext context,
  required int initialIndex,
  required PostGridController<T> controller,
  AutoScrollController? scrollController,
}) =>
    goToPostDetailsPageCore(
      context: context,
      posts: controller.items.toList(),
      initialIndex: initialIndex,
      scrollController: scrollController,
    );

void goToPostDetailsPageCore<T extends Post>({
  required BuildContext context,
  required List<T> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  context.push(
    Uri(
      path: '/details',
    ).toString(),
    extra: DetailsRoutePayload(
      initialIndex: initialIndex,
      posts: posts,
      scrollController: scrollController,
      isDesktop: context.isLargeScreen,
    ),
  );
}
