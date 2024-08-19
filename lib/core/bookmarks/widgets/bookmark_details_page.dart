// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';

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
      posts: bookmarks.map((e) => e.toPost()).toList(),
      swipeImageUrlBuilder: (post) => post.sampleImageUrl,
      toolbarBuilder: (context, post) => BookmarkPostActionToolbar(post: post),
      sourceSectionBuilder: (context, post) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          post.source.whenWeb(
            (source) => SourceSection(source: source),
            () => const SizedBox.shrink(),
          ),
          post.realSourceUrl.whenWeb(
            (source) => SourceSection(
              title: 'Original Source',
              source: source,
            ),
            () => const SizedBox.shrink(),
          ),
        ],
      ),
      topRightButtonsBuilder: (context, _, post, controller) => [
        GeneralMoreActionButton(
          post: post,
          onStartSlideshow: () => controller.startSlideshow(),
          onDownload: (post) {
            ref.bookmarks.downloadBookmarks(
              ref.watchConfig,
              [post.toBookmark()],
            );
          },
        ),
      ],
      initialIndex: widget.initialIndex,
      onExit: (page) {
        // TODO: implement onExit
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
    return PostActionToolbar(
      children: [
        BookmarkPostButton(post: post),
        IconButton(
          splashRadius: 16,
          onPressed: () {
            showDownloadStartToast(context);
            ref.bookmarks.downloadBookmarks(
              ref.watchConfig,
              [post.toBookmark()],
            );
          },
          icon: const Icon(
            Symbols.download,
          ),
        ),
        SharePostButton(post: post),
      ],
    );
  }
}
