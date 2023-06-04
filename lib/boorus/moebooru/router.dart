// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/moebooru/pages/posts.dart';
import 'package:boorusama/boorus/moebooru/pages/search/moebooru_search_page.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';

void goToMoebooruSearchPage(
  WidgetRef ref,
  BuildContext context, {
  String? tag,
}) {
  Navigator.of(context)
      .push(MoebooruSearchPage.routeOf(context, ref, tag: tag));
}

void goToMoebooruDetailsPage({
  required BuildContext context,
  required WidgetRef ref,
  required List<Post> posts,
  required int initialPage,
  AutoScrollController? scrollController,
  required Settings settings,
}) {
  Navigator.push(
    context,
    MoebooruPostDetailsPage.routeOf(
      context,
      ref,
      posts: posts,
      initialIndex: initialPage,
      scrollController: scrollController,
      settings: settings,
    ),
  );
}
