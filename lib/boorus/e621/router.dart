// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/pages/post_details/e621_post_details_page.dart';

void goToE621DetailsPage({
  required BuildContext context,
  required List<E621Post> posts,
  required int initialPage,
  AutoScrollController? scrollController,
}) {
  Navigator.push(
    context,
    E621PostDetailsPage.routeOf(
      context,
      posts: posts,
      initialIndex: initialPage,
      scrollController: scrollController,
    ),
  );
}
