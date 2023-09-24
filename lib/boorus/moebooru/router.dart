// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/boorus/moebooru/pages/posts/moebooru_post_details_desktop_page.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';

void goToMoebooruDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialPage,
  AutoScrollController? scrollController,
}) {
  if (isMobilePlatform() && context.orientation.isPortrait) {
    Navigator.push(
      context,
      MoebooruPostDetailsPage.routeOf(
        context,
        posts: posts,
        initialIndex: initialPage,
        scrollController: scrollController,
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => MoebooruPostDetailsDesktopPage(
        posts: posts,
        initialIndex: initialPage,
        onExit: (page) => scrollController?.scrollToIndex(page),
      ),
    );
  }
}
