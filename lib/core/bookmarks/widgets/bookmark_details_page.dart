// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/core/configs/ref.dart';
import 'package:boorusama/core/downloads/downloader.dart';
import 'package:boorusama/core/posts/details.dart';
import 'package:boorusama/core/posts/shares.dart';
import 'package:boorusama/core/posts/sources/source.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import '../bookmark_convert.dart';
import '../providers.dart';
import 'providers.dart';

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

    return PostDetailsScope(
      initialIndex: initialIndex,
      posts: posts,
      scrollController: null,
      child: const BookmarkDetailsPageInternal(),
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
      imageUrlBuilder: (post) => post.sampleImageUrl,
      uiBuilder: PostDetailsUIBuilder(
        preview: {
          DetailsPart.toolbar: (context) => const BookmarkPostActionToolbar(),
        },
        full: {
          DetailsPart.toolbar: (context) => const BookmarkPostActionToolbar(),
          DetailsPart.source: (context) => const BookmarkSourceSection(),
          DetailsPart.tags: (context) =>
              const DefaultInheritedTagList<BookmarkPost>(),
          DetailsPart.fileDetails: (context) =>
              const DefaultInheritedFileDetailsSection<BookmarkPost>(),
        },
      ),
      topRightButtonsBuilder: (controller) => [
        GeneralMoreActionButton(
          post: InheritedPost.of<BookmarkPost>(context),
          onStartSlideshow: () => controller.startSlideshow(),
          onDownload: (post) {
            ref.bookmarks.downloadBookmarks(
              ref.readConfig,
              [post.toBookmark()],
            );
          },
        ),
      ],
    );
  }
}

class BookmarkSourceSection extends ConsumerWidget {
  const BookmarkSourceSection({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final post = InheritedPost.of<BookmarkPost>(context);

    return SliverToBoxAdapter(
      child: Column(
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

    return SliverToBoxAdapter(
      child: PostActionToolbar(
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
      ),
    );
  }
}
