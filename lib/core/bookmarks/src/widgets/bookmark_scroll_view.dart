// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:i18n/i18n.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';
import 'package:sliver_tools/sliver_tools.dart';

// Project imports:
import '../../../../foundation/url_launcher.dart';
import '../../../config_widgets/website_logo.dart';
import '../../../configs/config/providers.dart';
import '../../../posts/listing/providers.dart';
import '../../../posts/listing/widgets.dart';
import '../../../posts/post/types.dart';
import '../../../widgets/booru_context_menu.dart';
import '../../../widgets/context_menu_tile.dart';
import '../../../widgets/widgets.dart';
import '../../types.dart';
import '../data/bookmark_convert.dart';
import '../data/providers.dart';
import '../providers/bookmark_provider.dart';
import '../providers/bookmark_shuffle_provider.dart';
import '../providers/local_providers.dart';
import '../routes/route_utils.dart';
import 'bookmark_appbar.dart';
import 'bookmark_booru_type_selector.dart';
import 'bookmark_search_bar.dart';
import 'bookmark_shuffle_button.dart';
import 'bookmark_sort_button.dart';

class BookmarkScrollView extends ConsumerStatefulWidget {
  const BookmarkScrollView({
    required this.scrollController,
    required this.searchController,
    super.key,
  });

  final AutoScrollController scrollController;
  final TextEditingController searchController;

  @override
  ConsumerState<BookmarkScrollView> createState() => _BookmarkScrollViewState();
}

class _BookmarkScrollViewState extends ConsumerState<BookmarkScrollView> {
  final _selectionModeController = SelectionModeController();

  List<String> _parseTagsFromText(String text) {
    return text.isEmpty
        ? <String>[]
        : text
              .trim()
              .replaceAll(RegExp(r'\s+'), ' ')
              .split(' ')
              .where((e) => e.isNotEmpty)
              .toList();
  }

  @override
  void dispose() {
    _selectionModeController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RawPostScope<BookmarkPost>(
      fetcher: (page) => TaskEither.Do(
        ($) async {
          final searchTags = _parseTagsFromText(widget.searchController.text);
          final sortType = ref.read(selectedBookmarkSortTypeProvider);
          final selectedBooruUrl = ref.read(selectedBooruUrlProvider);
          final shuffleState = ref.read(bookmarkShuffleProvider);
          final bookmarks = filterBookmarks(
            selectedTags: searchTags,
            bookmarks: await (await ref.read(bookmarkRepoProvider.future))
                .getAllBookmarksOrEmpty(
                  imageUrlResolver: (booruId) =>
                      ref.read(bookmarkUrlResolverProvider(booruId)),
                ),
            sortType: sortType,
            selectedBooruUrl: selectedBooruUrl,
            shuffleState: shuffleState,
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
            ..listen(selectedBooruUrlProvider, (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.refresh();
              });
            })
            ..listen(selectedBookmarkSortTypeProvider, (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.refresh();
              });
            })
            ..listen(bookmarkShuffleProvider, (_, _) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                controller.refresh();
              });
            });

          final auth = ref.watchConfigAuth;
          final download = ref.watchConfigDownload;

          return PostGrid(
            selectionModeController: _selectionModeController,
            scrollController: widget.scrollController,
            controller: controller,
            enablePullToRefresh: true,
            multiSelectActions: DefaultMultiSelectionActions(
              postController: controller,
              bookmark: false,
              onBulkDownload: (selectedPosts) {
                ref
                    .read(bookmarkProvider.notifier)
                    .downloadBookmarks(
                      auth,
                      download,
                      selectedPosts.map((e) => e.bookmark).toList(),
                    );
              },
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

                          _selectionModeController.disable();
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
                        context.t.bookmark.counter(n: posts.length),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                  PostGridConfigIconButton(
                    postController: controller,
                    showBlacklist: false,
                  ),
                ],
              ),
            ),
            itemBuilder: (context, index, autoScrollController, useHero) =>
                _buildItem(
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
                  controller: widget.searchController,
                  postController: controller,
                ),
              ),
              const SliverPinnedHeader(
                child: BookmarkBooruSourceUrlSelector(),
              ),
              const SliverSizedBox(height: 8),
              ValueListenableBuilder(
                valueListenable: controller.itemsNotifier,
                builder: (_, posts, _) => posts.isNotEmpty
                    ? const SliverToBoxAdapter(
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Row(
                            children: [
                              BookmarkSortButton(),
                              BookmarkShuffleButton(),
                            ],
                          ),
                        ),
                      )
                    : const SliverSizedBox.shrink(),
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
    final auth = ref.watchConfigAuth;

    return ValueListenableBuilder(
      valueListenable: controller.itemsNotifier,
      builder: (_, posts, _) {
        final post = posts[index];

        return Stack(
          children: [
            BookmarkContextMenu(
              post: post,
              index: index,
              controller: controller,
              child: DefaultImageGridItem(
                index: index,
                autoScrollController: widget.scrollController,
                controller: controller,
                imageUrl: post.isVideo
                    ? post.thumbnailImageUrl
                    : post.sampleImageUrl,
                imageCacheManager: ref.watch(bookmarkImageCacheManagerProvider),
                useHero: false,
                config: auth,
                leadingIcons: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: ConfigAwareWebsiteLogo(url: post.bookmark.sourceUrl),
                  ),
                ],
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

class BookmarkContextMenu extends ConsumerWidget {
  const BookmarkContextMenu({
    super.key,
    required this.post,
    required this.index,
    required this.controller,
    required this.child,
  });

  final BookmarkPost post;
  final int index;
  final PostGridController<BookmarkPost> controller;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watchConfigAuth;
    final loginDetails = ref.watch(booruLoginDetailsProvider(auth));
    final download = ref.watchConfigDownload;

    return BooruContextMenu(
      menuItemsBuilder: (context) => [
        ContextMenuTile(
          title: context.t.download.download,
          onTap: () => ref.bookmarks.downloadBookmarks(
            auth,
            download,
            [post.bookmark],
          ),
        ),
        ContextMenuTile(
          title: context.t.post.detail.remove_from_bookmark,
          onTap: () => ref.bookmarks.removeBookmark(
            post.bookmark,
            onSuccess: () {
              controller.remove([post.id], (e) => e.id);
            },
          ),
        ),
        if (!loginDetails.hasStrictSFW)
          ContextMenuTile(
            title: 'Open source in browser',
            onTap: () => launchExternalUrlString(post.bookmark.sourceUrl),
          ),
      ],
      child: child,
    );
  }
}
