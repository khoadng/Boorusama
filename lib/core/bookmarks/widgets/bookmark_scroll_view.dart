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
          backgroundColor: context.colorScheme.surface,
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
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(
                '${ref.watch(filteredBookmarksProvider).length} bookmarks',
                style: context.textTheme.titleLarge,
              ),
            ),
          ),
        if (hasBookmarks)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Row(
                children: [
                  BookmarkSortButton(),
                  Spacer(),
                  BookmarkGridUpdateButtons(),
                ],
              ),
            ),
          ),
        const SliverSizedBox(height: 8),
        const SliverBookmarkGrid(),
      ],
    );
  }
}

class SliverBookmarkGrid extends ConsumerWidget {
  const SliverBookmarkGrid({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spacing = ref.watch(imageListingSettingsProvider.select(
      (value) => value.imageGridSpacing,
    ));
    final padding = ref.watch(imageListingSettingsProvider.select(
      (value) => value.imageGridPadding,
    ));
    final hasBookmarks = ref.watch(hasBookmarkProvider);
    final bookmarks = ref.watch(filteredBookmarksProvider);

    return hasBookmarks
        ? SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: padding,
            ),
            sliver: bookmarks.isEmpty
                ? const SliverToBoxAdapter(
                    child: NoDataBox(),
                  )
                : SliverMasonryGrid.count(
                    crossAxisCount: ref
                        .watch(selectRowCountProvider(Screen.of(context).size)),
                    mainAxisSpacing: spacing,
                    crossAxisSpacing: spacing,
                    childCount: bookmarks.length,
                    itemBuilder: (context, index) => _buildItem(
                      ref,
                      bookmarks[index],
                      index,
                    ),
                  ),
          )
        : const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 16),
              child: Text(
                'No bookmarks',
                style: TextStyle(fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
            ),
          );
  }

  Widget _buildItem(
    WidgetRef ref,
    Bookmark bookmark,
    int index,
  ) {
    final edit = ref.watch(bookmarkEditProvider);
    final borderRadius = ref.watch(imageListingSettingsProvider.select(
      (value) => value.imageBorderRadius,
    ));
    final context = ref.context;

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
            onPressed: () => ref.bookmarks.removeBookmarkWithToast(
              context,
              bookmark,
            ),
          ),
          if (!ref.watchConfig.hasStrictSFW)
            ContextMenuButtonConfig(
              'Open source in browser',
              onPressed: () => launchExternalUrlString(bookmark.sourceUrl),
            ),
        ],
      ),
      child: Stack(
        children: [
          ImageGridItem(
            borderRadius: BorderRadius.circular(
              borderRadius,
            ),
            isAnimated: bookmark.isVideo,
            isAI: bookmark.isAI,
            onTap: () => goToBookmarkDetailsPage(context, index),
            image: BooruImage(
              borderRadius: BorderRadius.circular(borderRadius),
              aspectRatio: bookmark.aspectRatio,
              fit: BoxFit.cover,
              imageUrl:
                  bookmark.isVideo ? bookmark.thumbnailUrl : bookmark.sampleUrl,
              placeholderUrl: bookmark.thumbnailUrl,
            ),
          ),
          Positioned(
            top: 4,
            left: 4,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: BooruLogo(source: bookmark.sourceUrl),
            ),
          ),
          if (edit)
            Positioned(
              top: 5,
              right: 5,
              child: CircularIconButton(
                padding: const EdgeInsets.all(4),
                icon: const Icon(Symbols.close),
                onPressed: () =>
                    ref.bookmarks.removeBookmarkWithToast(context, bookmark),
              ),
            ),
        ],
      ),
    );
  }
}
