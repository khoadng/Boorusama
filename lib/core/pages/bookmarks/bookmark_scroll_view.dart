// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/bookmarks/bookmarks.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/pages/bookmarks/bookmark_sort_button.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';
import 'bookmark_booru_type_selector.dart';
import 'providers.dart';

class BookmarkScrollView extends ConsumerWidget {
  const BookmarkScrollView({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final edit = ref.watch(bookmarkEditProvider);

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              '${ref.watch(filteredBookmarksProvider).length} bookmarks',
              style: context.textTheme.titleLarge,
            ),
          ),
        ),
        const SliverToBoxAdapter(
          child: Row(
            children: [
              BookmarkBooruTypeSelector(),
              BookmarkSortButton(),
              Spacer(),
            ],
          ),
        ),
        const SliverSizedBox(height: 8),
        Builder(
          builder: (context) {
            final bookmarks = ref.watch(filteredBookmarksProvider);

            if (bookmarks.isEmpty) {
              return const SliverToBoxAdapter(
                child: NoDataBox(),
              );
            }

            return SliverMasonryGrid.count(
              crossAxisCount: switch (Screen.of(context).size) {
                ScreenSize.small => 2,
                ScreenSize.medium => 3,
                ScreenSize.large => 5,
                ScreenSize.veryLarge => 6,
              },
              mainAxisSpacing: settings.imageGridSpacing,
              crossAxisSpacing: settings.imageGridSpacing,
              childCount: bookmarks.length,
              itemBuilder: (context, index) {
                final bookmark = bookmarks[index];
                final source = PostSource.from(bookmark.sourceUrl);

                return ContextMenuRegion(
                  contextMenu: GenericContextMenu(
                    buttonConfigs: [
                      ContextMenuButtonConfig(
                        'download.download'.tr(),
                        onPressed: () =>
                            ref.bookmarks.downloadBookmarks([bookmark]),
                      ),
                      // remove bookmark
                      ContextMenuButtonConfig(
                        'post.detail.remove_from_bookmark'.tr(),
                        onPressed: () => ref.bookmarks.removeBookmarkWithToast(
                          bookmark,
                        ),
                      ),
                      ContextMenuButtonConfig(
                        'Open source in browser',
                        onPressed: () =>
                            launchExternalUrlString(bookmark.sourceUrl),
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ImageGridItem(
                        isAnimated: bookmark.isVideo,
                        isAI: bookmark.isAI,
                        onTap: () =>
                            context.go('/bookmarks/details?index=$index'),
                        image: BooruImage(
                          borderRadius:
                              BorderRadius.circular(settings.imageBorderRadius),
                          aspectRatio: bookmark.aspectRatio,
                          fit: BoxFit.cover,
                          imageUrl: bookmark.isVideo
                              ? bookmark.thumbnailUrl
                              : bookmark.sampleUrl,
                          placeholderUrl: bookmark.thumbnailUrl,
                        ),
                      ),
                      source.whenWeb(
                        (url) => Positioned(
                          bottom: 5,
                          right: 5,
                          child: BooruLogo(
                            source: url,
                          ),
                        ),
                        () => const SizedBox(),
                      ),
                      if (edit)
                        Positioned(
                          top: 5,
                          right: 5,
                          child: CircularIconButton(
                            padding: const EdgeInsets.all(4),
                            icon: const Icon(Icons.close),
                            onPressed: () =>
                                ref.bookmarks.removeBookmarkWithToast(bookmark),
                          ),
                        ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}
