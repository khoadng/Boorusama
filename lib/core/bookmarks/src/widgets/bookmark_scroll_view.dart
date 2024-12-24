// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../providers/bookmark_provider.dart';
import '../providers/local_providers.dart';
import 'bookmark_appbar.dart';
import 'bookmark_booru_type_selector.dart';
import 'bookmark_search_bar.dart';
import 'bookmark_sort_button.dart';
import 'bookmark_update_grid_buttons.dart';
import 'sliver_bookmark_grid.dart';

class BookmarkScrollView extends ConsumerWidget {
  const BookmarkScrollView({
    required this.controller,
    required this.focusNode,
    required this.searchController,
    super.key,
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
          backgroundColor: Theme.of(context).colorScheme.surface,
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
                style: Theme.of(context).textTheme.titleLarge,
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
