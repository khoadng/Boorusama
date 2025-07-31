// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../../boorus/engine/engine.dart';
import '../../../configs/config/providers.dart';
import '../../../configs/config/types.dart';
import '../../../downloads/downloader/providers.dart';
import '../../../posts/details/details.dart';
import '../../../posts/details/widgets.dart';
import '../../../posts/details_manager/types.dart';
import '../../../posts/details_parts/widgets.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/post/post.dart';
import '../../../posts/sources/source.dart';
import '../../../widgets/adaptive_button_row.dart';
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
    final imageCacheManager = ref.watch(bookmarkImageCacheManagerProvider);
    final auth = ref.watchConfigAuth;

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
    final controller = PostDetails.of<BookmarkPost>(context).pageViewController;
    final config = ref.watch(
      firstMatchingConfigProvider(post.bookmark.booruId),
    );
    final originalPost = post.toOriginalPost();

    return SliverToBoxAdapter(
      child: CommonPostButtonsBuilder(
        post: originalPost,
        onStartSlideshow: controller.startSlideshow,
        config: config?.auth,
        configViewer: config?.viewer,
        copy: false,
        builder: (context, buttons) {
          return AdaptiveButtonRow.menu(
            buttonWidth: 52,
            maxVisibleButtons: 4,
            buttons: [
              if (config != null)
                ButtonData(
                  required: true,
                  widget: BookmarkPostButton(
                    post: post,
                    config: config.auth,
                  ),
                  title: context.t.post.action.bookmark,
                ),
              if (config != null)
                ButtonData(
                  required: true,
                  widget: IconButton(
                    splashRadius: 16,
                    onPressed: () {
                      showDownloadStartToast(context);
                      ref.bookmarks.downloadBookmarks(
                        config,
                        [post.bookmark],
                      );
                    },
                    icon: const Icon(
                      Symbols.download,
                    ),
                  ),
                  title: context.t.download.download,
                ),

              ...buttons,
            ],
          );
        },
      ),
    );
  }
}
