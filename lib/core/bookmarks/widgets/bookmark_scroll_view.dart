// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/bookmarks/bookmarks.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/display.dart';
import 'package:boorusama/foundation/i18n.dart';
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/foundation/url_launcher.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class BookmarkScrollView extends ConsumerWidget {
  const BookmarkScrollView({
    super.key,
    required this.controller,
    required this.focusNode,
    required this.searchController,
  });

  final ScrollController controller;
  final TextEditingController searchController;
  final FocusNode focusNode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageListingSettingsProvider);
    final edit = ref.watch(bookmarkEditProvider);
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    return CustomScrollView(
      controller: controller,
      slivers: [
        SliverAppBar(
          floating: true,
          snap: true,
          pinned: true,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          backgroundColor: context.theme.scaffoldBackgroundColor,
          title: const BookmarkAppBar(),
        ),
        SliverToBoxAdapter(
          child: BookmarkSearchBar(
            focusNode: focusNode,
            controller: searchController,
          ),
        ),
        if (hasBookmarks)
          const SliverPinnedHeader(
            child: BookmarkBooruSourceUrlSelector(),
          ),
        const SliverSizedBox(height: 8),
        if (hasBookmarks)
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                '${ref.watch(filteredBookmarksProvider).length} bookmarks',
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
        if (hasBookmarks)
          const SliverToBoxAdapter(
            child: Row(
              children: [
                BookmarkSortButton(),
                Spacer(),
                BookmarkGridUpdateButtons(),
              ],
            ),
          ),
        const SliverSizedBox(height: 8),
        if (hasBookmarks)
          Builder(
            builder: (context) {
              final bookmarks = ref.watch(filteredBookmarksProvider);

              if (bookmarks.isEmpty) {
                return const SliverToBoxAdapter(
                  child: NoDataBox(),
                );
              }

              return SliverMasonryGrid.count(
                crossAxisCount:
                    ref.watch(selectRowCountProvider(Screen.of(context).size)),
                mainAxisSpacing: settings.imageGridSpacing,
                crossAxisSpacing: settings.imageGridSpacing,
                childCount: bookmarks.length,
                itemBuilder: (context, index) {
                  final bookmark = bookmarks[index];

                  return ContextMenuRegion(
                    contextMenu: GenericContextMenu(
                      buttonConfigs: [
                        ContextMenuButtonConfig(
                          'download.download'.tr(),
                          onPressed: () => ref.bookmarks.downloadBookmarks(
                            ref.watchConfig,
                            [bookmark],
                          ),
                        ),
                        // remove bookmark
                        ContextMenuButtonConfig(
                          'post.detail.remove_from_bookmark'.tr(),
                          onPressed: () =>
                              ref.bookmarks.removeBookmarkWithToast(
                            context,
                            bookmark,
                          ),
                        ),
                        if (!ref.watchConfig.hasStrictSFW)
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
                          borderRadius: BorderRadius.circular(
                            settings.imageBorderRadius,
                          ),
                          isAnimated: bookmark.isVideo,
                          isAI: bookmark.isAI,
                          onTap: () =>
                              context.go('/bookmarks/details?index=$index'),
                          image: BooruImage(
                            borderRadius: BorderRadius.circular(
                                settings.imageBorderRadius),
                            aspectRatio: bookmark.aspectRatio,
                            fit: BoxFit.cover,
                            imageUrl: bookmark.isVideo
                                ? bookmark.thumbnailUrl
                                : bookmark.sampleUrl,
                            placeholderUrl: bookmark.thumbnailUrl,
                          ),
                        ),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: BooruLogo(source: bookmark.sourceUrl),
                        ),
                        if (edit)
                          Positioned(
                            top: 5,
                            right: 5,
                            child: CircularIconButton(
                              padding: const EdgeInsets.all(4),
                              icon: const Icon(
                                Symbols.close,
                                color: Colors.white,
                              ),
                              onPressed: () => ref.bookmarks
                                  .removeBookmarkWithToast(context, bookmark),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          )
        else
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text(
                'No bookmarks',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          ),
      ],
    );
  }
}
