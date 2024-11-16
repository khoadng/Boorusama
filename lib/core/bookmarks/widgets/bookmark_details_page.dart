// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/downloads/downloads.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/widgets/widgets.dart';

class BookmarkDetailsPage extends ConsumerWidget {
  const BookmarkDetailsPage({
    super.key,
    required this.initialIndex,
  });

  final int initialIndex;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookmarks = ref.watch(filteredBookmarksProvider);
    final posts = bookmarks.map((e) => e.toPost()).toList();

    return PostDetailsLayoutSwitcher(
      initialIndex: initialIndex,
      posts: posts,
      desktop: null,
      mobile: () => const BookmarkDetailsPageInternal(),
      scrollController: null,
    );
  }
}

class BookmarkDetailsPageInternal extends ConsumerStatefulWidget {
  const BookmarkDetailsPageInternal({
    super.key,
  });

  @override
  ConsumerState<BookmarkDetailsPageInternal> createState() =>
      _BookmarkDetailsPageState();
}

class _BookmarkDetailsPageState
    extends ConsumerState<BookmarkDetailsPageInternal> {
  @override
  Widget build(BuildContext context) {
    final data = PostDetails.of<BookmarkPost>(context);
    final posts = data.posts;
    final controller = data.controller;

    return PostDetailsPageScaffold(
      controller: controller,
      posts: posts,
      swipeImageUrlBuilder: (post) => post.sampleImageUrl,
      uiBuilder: PostDetailsUIBuilder(
        toolbarBuilder: (context) => const BookmarkPostActionToolbar(),
      ),
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
    );
  }
}

class BookmarkPostActionToolbar extends ConsumerWidget {
  const BookmarkPostActionToolbar({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<BookmarkPost>(context);

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
