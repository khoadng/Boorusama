import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:i18n/i18n.dart';

import 'package:boorusama/core/bookmarks/src/data/bookmark_convert.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/posts/listing/providers.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/posts/post/types.dart';

/// Localized strings of the mounted app, for finders that match visible text.
Translations appStrings(WidgetTester tester) =>
    tester.element(find.byType(Navigator).first).t;

Finder postGrid() => find.byType(PostGrid<Post>);

Finder postGridScrollable() => find
    .descendant(
      of: find.byType(PostGrid).first,
      matching: find.byType(Scrollable),
    )
    .first;

Finder postTile(int id) => find.byWidgetPredicate(
  (widget) => widget is SliverPostGridImageGridItem && widget.post.id == id,
  description: 'post tile with ID $id',
);

/// A listing tile (not a bookmark tile) whose post carries [tag].
Finder listingPostWithTag(String tag) => find.byWidgetPredicate(
  (widget) =>
      widget is SliverPostGridImageGridItem &&
      widget.post is! BookmarkPost &&
      widget.post.tags.contains(tag),
  description: 'listing post tagged $tag',
);

Finder bookmarkTile({
  required int postId,
  required int booruId,
  String? sourceUrl,
}) => find.byWidgetPredicate(
  (widget) => switch (widget) {
    SliverPostGridImageGridItem(post: BookmarkPost(:final bookmark)) =>
      bookmark.postId == postId &&
          bookmark.booruId == booruId &&
          (sourceUrl == null || bookmark.sourceUrl == sourceUrl),
    _ => false,
  },
  description:
      'bookmark tile for post $postId from booru $booruId'
      '${sourceUrl == null ? '' : ' at $sourceUrl'}',
);

Finder postDetailsScaffold() => find.byWidgetPredicate(
  (widget) => widget is PostDetailsPageScaffold,
  description: 'post details scaffold',
);

PostGridController<Post> postController(WidgetTester tester) =>
    PostScope.of<Post>(tester.element(postGrid().first));

List<int> loadedPostIds(WidgetTester tester) =>
    postController(tester).allItems.map((post) => post.id).toList();

Post currentDetailPost(WidgetTester tester) => tester
    .widget<PostDetailsPageScaffold>(
      postDetailsScaffold().first,
    )
    .controller
    .currentPost
    .value;
