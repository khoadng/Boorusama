// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:page_transition/page_transition.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/pages/search/simple_search_page.dart';
import 'package:boorusama/boorus/core/pages/simple_post_details_page.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/utils/flutter_utils.dart';

void goToZerochanSearchPage(
  BuildContext context, {
  String? tag,
}) {
  context.navigator.push(PageTransition(
    type: PageTransitionType.fade,
    child: CustomContextMenuOverlay(
      child: SimpleSearchPage(
          initialQuery: tag,
          onPostTap: (context, posts, post, scrollController, settings,
                  initialIndex) =>
              goToZerochanPostDetailsPage(
                context: context,
                posts: posts,
                initialIndex: initialIndex,
                scrollController: scrollController,
              )),
    ),
  ));
}

void goToZerochanPostDetailsPage({
  required BuildContext context,
  required List<Post> posts,
  required int initialIndex,
  AutoScrollController? scrollController,
}) {
  context.navigator.push(MaterialPageRoute(
    builder: (_) => SimplePostDetailsPage(
      posts: posts,
      initialIndex: initialIndex,
      onExit: (page) => scrollController?.scrollToIndex(page),
      onTagTap: (tag) => goToZerochanSearchPage(context, tag: tag),
    ),
  ));
}
