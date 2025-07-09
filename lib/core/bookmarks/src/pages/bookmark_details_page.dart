// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../configs/ref.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../posts/details/details.dart';
import '../../../posts/details/widgets.dart';
import '../../../posts/details_manager/types.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/post/post.dart';
import '../../../posts/shares/widgets.dart';
import '../../../posts/sources/source.dart';
import '../../../widgets/widgets.dart';
import '../data/bookmark_convert.dart';
import '../providers/bookmark_provider.dart';
import '../widgets/bookmark_tag_tiles.dart';

class BookmarkDetailsPage extends ConsumerWidget {
  const BookmarkDetailsPage({
    required this.initialIndex,
    required this.initialThumbnailUrl,
    required this.controller,
    super.key,
  });

  final int initialIndex;
  final String? initialThumbnailUrl;
  final PostGridController<BookmarkPost> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: controller.itemsNotifier,
      builder: (_, posts, _) {
        return PostDetailsScope(
          initialIndex: initialIndex,
          initialThumbnailUrl: initialThumbnailUrl,
          posts: posts,
          scrollController: null,
          dislclaimer: null,
          child: const BookmarkDetailsPageInternal(),
        );
      },
    );
  }
}

final bookmarkUiBuilder = PostDetailsUIBuilder(
  preview: {
    DetailsPart.toolbar: (context) => const BookmarkPostActionToolbar(),
  },
  full: {
    DetailsPart.toolbar: (context) => const BookmarkPostActionToolbar(),
    DetailsPart.source: (context) => const BookmarkSourceSection(),
    DetailsPart.tags: (context) => const BookmarkTagTiles(),
    DetailsPart.fileDetails: (context) =>
        const DefaultInheritedFileDetailsSection<BookmarkPost>(),
  },
);

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
    final pageViewController = data.pageViewController;
    final imageCacheManager = ref.watch(bookmarkImageCacheManagerProvider);
    final auth = ref.watchConfigAuth;
    final viewer = ref.watchConfigViewer;
    final post = InheritedPost.of<BookmarkPost>(context);

    return PostDetailsPageScaffold(
      pageViewController: data.pageViewController,
      controller: controller,
      posts: posts,
      viewerConfig: ref.watchConfigViewer,
      authConfig: auth,
      gestureConfig: ref.watchPostGestures,
      // Needed to prevent type inference error
      // ignore: avoid_types_on_closure_parameters
      imageUrlBuilder: (Post post) => post.originalImageUrl,
      imageCacheManager: (_) => imageCacheManager,
      uiBuilder: bookmarkUiBuilder,
      preferredParts: bookmarkUiBuilder.full.keys.toSet(),
      preferredPreviewParts: bookmarkUiBuilder.preview.keys.toSet(),
      topRightButtons: [
        GeneralMoreActionButton(
          post: post,
          config: auth,
          configViewer: viewer,
          onStartSlideshow: () => pageViewController.startSlideshow(),
          onDownload: (_) {
            ref.bookmarks.downloadBookmarks(
              ref.readConfig,
              [
                post.toBookmark(
                  imageUrlResolver: (booruId) =>
                      ref.read(bookmarkUrlResolverProvider(booruId)),
                ),
              ],
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
                [
                  post.toBookmark(
                    imageUrlResolver: (booruId) =>
                        ref.read(bookmarkUrlResolverProvider(booruId)),
                  ),
                ],
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
