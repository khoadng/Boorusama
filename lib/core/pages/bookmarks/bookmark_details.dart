// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/scaffolds/scaffolds.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/path.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'providers.dart';

class BookmarkDetailsPage extends ConsumerStatefulWidget {
  const BookmarkDetailsPage({
    super.key,
    required this.initialIndex,
  });

  final int initialIndex;

  @override
  ConsumerState<BookmarkDetailsPage> createState() =>
      _BookmarkDetailsPageState();
}

class _BookmarkDetailsPageState extends ConsumerState<BookmarkDetailsPage> {
  @override
  Widget build(BuildContext context) {
    final bookmarks = ref.watch(filteredBookmarksProvider);

    return PostDetailsPageScaffold(
      posts: bookmarks
          .map(
            (e) => SimplePost(
              id: e.id,
              thumbnailImageUrl: e.thumbnailUrl,
              sampleImageUrl: e.sampleUrl,
              originalImageUrl: e.originalUrl,
              tags: e.tags,
              rating: Rating.unknown,
              hasComment: false,
              isTranslated: false,
              hasParentOrChildren: false,
              source: PostSource.from(e.sourceUrl),
              score: 0,
              duration: 0,
              fileSize: 0,
              format: extension(e.originalUrl),
              hasSound: null,
              height: e.height,
              md5: e.md5,
              videoThumbnailUrl: e.thumbnailUrl,
              videoUrl: e.originalUrl,
              width: e.width,
              getLink: (_) => e.sourceUrl,
            ),
          )
          .toList(),
      swipeImageUrlBuilder: (post) => post.sampleImageUrl,
      toolbarBuilder: (context, post) => BookmarkPostActionToolbar(post: post),
      initialIndex: widget.initialIndex,
      onExit: (page) {
        // TODO: implement onExit
      },
      onTagTap: (tag) {
        // TODO: implement onTagTap
      },
    );
  }
}

class BookmarkPostActionToolbar extends ConsumerWidget {
  const BookmarkPostActionToolbar({
    super.key,
    required this.post,
  });

  final Post post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Material(
      color: context.theme.scaffoldBackgroundColor,
      child: ButtonBar(
        buttonPadding: EdgeInsets.zero,
        alignment: MainAxisAlignment.spaceEvenly,
        children: [
          BookmarkPostButton(post: post),
          DownloadPostButton(post: post),
          SharePostButton(post: post),
        ],
      ),
    );
  }
}
