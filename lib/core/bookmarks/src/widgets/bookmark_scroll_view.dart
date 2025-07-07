// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../config_widgets/booru_logo.dart';
import '../../../configs/ref.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/listing/src/_internal/default_image_grid_item.dart';
import '../../../posts/listing/src/_internal/post_grid_config_icon_button.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/post.dart';
import '../../../widgets/widgets.dart';
import '../../bookmark.dart';
import '../data/bookmark_convert.dart';
import '../data/providers.dart';
import '../providers/bookmark_provider.dart';
import '../providers/local_providers.dart';
import '../routes/route_utils.dart';
import 'bookmark_appbar.dart';
import 'bookmark_booru_type_selector.dart';
import 'bookmark_search_bar.dart';
import 'bookmark_sort_button.dart';

class BookmarkScrollView extends ConsumerStatefulWidget {
  const BookmarkScrollView({
    required this.scrollController,
    required this.focusNode,
    required this.searchController,
    super.key,
  });

  final AutoScrollController scrollController;
  final TextEditingController searchController;
  final FocusNode focusNode;

  @override
  ConsumerState<BookmarkScrollView> createState() => _BookmarkScrollViewState();
}

class _BookmarkScrollViewState extends ConsumerState<BookmarkScrollView> {
  final _multiSelectController = MultiSelectController();

  @override
  void dispose() {
    _multiSelectController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasBookmarks = ref.watch(hasBookmarkProvider);

    return RawPostScope<BookmarkPost>(
      fetcher: (page) => TaskEither.Do(
        ($) async {
          final selectedTags = ref.read(selectedTagsProvider);
          final sortType = ref.read(selectedBookmarkSortTypeProvider);
          final selectedBooruUrl = ref.read(selectedBooruUrlProvider);
          final bookmarks = filterBookmarks(
            tags: selectedTags,
            bookmarks: await (await ref.read(bookmarkRepoProvider.future))
                .getAllBookmarksOrEmpty(
                  imageUrlResolver: (booruId) =>
                      ref.read(bookmarkUrlResolverProvider(booruId)),
                ),
            sortType: sortType,
            selectedBooruUrl: selectedBooruUrl,
          );
          final posts = bookmarks.map((bookmark) => bookmark.toPost()).toList();

          return page == 1
              ? PostResult(
                  posts: posts,
                  total: posts.length,
                )
              : PostResult.empty();
        },
      ),
      builder: (context, controller) => Consumer(
        builder: (context, ref, child) {
          ref
            ..listen(selectedTagsProvider, (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.refresh();
              });
            })
            ..listen(selectedBooruUrlProvider, (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.refresh();
              });
            })
            ..listen(selectedBookmarkSortTypeProvider, (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.refresh();
              });
            });

          return PostGrid(
            multiSelectController: _multiSelectController,
            scrollController: widget.scrollController,
            controller: controller,
            enablePullToRefresh: false,
            multiSelectActions: DefaultMultiSelectionActions(
              controller: _multiSelectController,
              postController: controller,
              bookmark: false,
              extraActions: (selectedPosts) => [
                MultiSelectButton(
                  onPressed: selectedPosts.isNotEmpty
                      ? () {
                          final bookmarks = selectedPosts
                              .map((e) => e.bookmark)
                              .toList();

                          ref
                              .read(bookmarkProvider.notifier)
                              .removeBookmarks(bookmarks)
                              .then((_) {
                                if (context.mounted) {
                                  controller.remove(
                                    selectedPosts.map((e) => e.id).toList(),
                                    (e) => e.id,
                                  );
                                }
                              });

                          _multiSelectController.disableMultiSelect();
                        }
                      : null,
                  icon: const Icon(Symbols.bookmark_remove),
                  name: 'Remove',
                ),
              ],
            ),
            header: Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: ValueListenableBuilder(
                      valueListenable: controller.itemsNotifier,
                      builder: (_, posts, _) => Text(
                        '${posts.length} bookmarks',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  PostGridConfigIconButton(
                    multiSelectController: _multiSelectController,
                    postController: controller,
                    showBlacklist: false,
                  ),
                ],
              ),
            ),
            itemBuilder:
                (
                  context,
                  index,
                  multiSelectController,
                  autoScrollController,
                  useHero,
                ) => _buildItem(
                  index,
                  controller,
                ),
            sliverHeaders: [
              SliverAppBar(
                floating: true,
                snap: true,
                pinned: true,
                automaticallyImplyLeading: false,
                titleSpacing: 0,
                backgroundColor: Theme.of(context).colorScheme.surface,
                title: BookmarkAppBar(
                  controller: controller,
                ),
              ),
              SliverToBoxAdapter(
                child: BookmarkSearchBar(
                  focusNode: widget.focusNode,
                  controller: widget.searchController,
                ),
              ),
              if (hasBookmarks)
                const SliverPinnedHeader(
                  child: BookmarkBooruSourceUrlSelector(),
                ),
              const SliverSizedBox(height: 8),
              if (hasBookmarks)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        BookmarkSortButton(),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildItem(
    int index,
    PostGridController<BookmarkPost> controller,
  ) {
    final edit = ref.watch(bookmarkEditProvider);

    final config = ref.watchConfigAuth;

    return ValueListenableBuilder(
      valueListenable: controller.itemsNotifier,
      builder: (_, posts, _) {
        final post = posts[index];

        return Stack(
          children: [
            DefaultImageGridItem(
              index: index,
              multiSelectController: _multiSelectController,
              autoScrollController: widget.scrollController,
              controller: controller,
              imageUrl: post.isVideo
                  ? post.thumbnailImageUrl
                  : post.sampleImageUrl,
              imageCacheManager: ref.watch(bookmarkImageCacheManagerProvider),
              useHero: false,
              leadingIcons: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: BooruLogo(source: post.bookmark.sourceUrl),
                ),
              ],
              contextMenu: GenericContextMenu(
                buttonConfigs: [
                  ContextMenuButtonConfig(
                    'download.download'.tr(),
                    onPressed: () => ref.bookmarks.downloadBookmarks(
                      ref.readConfig,
                      [post.bookmark],
                    ),
                  ),
                  // remove bookmark
                  ContextMenuButtonConfig(
                    'post.detail.remove_from_bookmark'.tr(),
                    onPressed: () => ref.bookmarks.removeBookmark(
                      post.bookmark,
                      onSuccess: () {
                        controller.remove([post.id], (e) => e.id);
                      },
                    ),
                  ),
                  if (!config.hasStrictSFW)
                    ContextMenuButtonConfig(
                      'Open source in browser',
                      onPressed: () =>
                          launchExternalUrlString(post.bookmark.sourceUrl),
                    ),
                ],
              ),
              onTap: () {
                goToBookmarkDetailsPage(
                  ref,
                  index,
                  initialThumbnailUrl: post.isVideo
                      ? post.bookmark.thumbnailUrl
                      : post.sampleImageUrl,
                  controller: controller,
                );
              },
            ),
            if (edit)
              Positioned(
                top: 5,
                right: 5,
                child: CircularIconButton(
                  padding: const EdgeInsets.all(4),
                  icon: const Icon(Symbols.close),
                  onPressed: () => ref.bookmarks.removeBookmark(
                    post.bookmark,
                    onSuccess: () {
                      controller.remove([post.id], (e) => e.id);
                    },
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
