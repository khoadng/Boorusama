// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/router.dart';
import 'package:boorusama/boorus/e621/feats/posts/posts.dart';
import 'package:boorusama/boorus/e621/pages/artists/e621_artist_page.dart';
import 'package:boorusama/boorus/e621/pages/favorites/e621_favorites_page.dart';
import 'package:boorusama/boorus/e621/pages/post_details/e621_post_details_desktop_page.dart';
import 'package:boorusama/boorus/e621/pages/post_details/e621_post_details_page.dart';
import 'package:boorusama/flutter.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/routes.dart';

void goToE621DetailsPage({
  required BuildContext context,
  required List<E621Post> posts,
  required int initialPage,
  AutoScrollController? scrollController,
}) {
  if (isMobilePlatform() && context.orientation.isPortrait) {
    Navigator.push(
      context,
      E621PostDetailsPage.routeOf(
        context,
        posts: posts,
        initialIndex: initialPage,
        scrollController: scrollController,
      ),
    );
  } else {
    showDesktopFullScreenWindow(
      context,
      builder: (context) => E621PostDetailsDesktopPage(
        initialIndex: initialPage,
        posts: posts,
        onExit: (index) => scrollController?.scrollToIndex(index),
      ),
    );
  }
}

void goToE621SearchPage(
  BuildContext context, {
  String? tag,
}) {
  if (tag == null) {
    context.push('/search');
  } else {
    context.push('/search?$kInitialQueryKey=$tag');
  }
}

void goToE621FavoritesPage(BuildContext context) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => E621FavoritesPage.of(context),
  ));
}

void goToE621ArtistPage(BuildContext context, String artist) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => E621ArtistPage.of(context, artist),
  ));
}
