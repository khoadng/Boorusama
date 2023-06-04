// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/authentication/authentication.dart';
import 'package:boorusama/boorus/core/posts/posts.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/settings/settings.dart';
import 'package:boorusama/boorus/core/ui/booru_image.dart';
import 'package:boorusama/boorus/core/ui/booru_image_legacy.dart';
import 'package:boorusama/boorus/core/ui/download_provider_widget.dart';
import 'package:boorusama/boorus/core/ui/image_grid_item.dart';
import 'package:boorusama/boorus/core/ui/multi_select_controller.dart';
import 'package:boorusama/boorus/core/ui/post_grid.dart';
import 'package:boorusama/boorus/core/ui/post_grid_controller.dart';
import 'package:boorusama/boorus/core/ui/sliver_post_grid.dart';
import 'package:boorusama/boorus/danbooru/features/posts/models.dart';
import 'package:boorusama/boorus/danbooru/pages/posts.dart';
import 'package:boorusama/boorus/danbooru/pages/shared/danbooru_image_grid_item.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/utils/double_utils.dart';

class DanbooruInfinitePostList extends ConsumerStatefulWidget {
  const DanbooruInfinitePostList({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaderBuilder,
    this.scrollController,
    this.contextMenuBuilder,
    this.multiSelectActions,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.controller,
    this.refreshAtStart = true,
    this.errors,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final Widget Function(Post post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;

  final bool refreshAtStart;

  final BooruError? errors;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  final PostGridController<DanbooruPost> controller;

  @override
  ConsumerState<DanbooruInfinitePostList> createState() =>
      _DanbooruInfinitePostListState();
}

class _DanbooruInfinitePostListState
    extends ConsumerState<DanbooruInfinitePostList> {
  late final AutoScrollController _autoScrollController;
  final _multiSelectController = MultiSelectController<DanbooruPost>();
  var multiSelect = false;

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
    _multiSelectController.addListener(() {
      setState(() {
        multiSelect = _multiSelectController.multiSelectEnabled;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    _multiSelectController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authenticationProvider);

    final settings = ref.watch(settingsProvider);

    return PostGrid(
      refreshAtStart: widget.refreshAtStart,
      controller: widget.controller,
      scrollController: _autoScrollController,
      sliverHeaderBuilder: widget.sliverHeaderBuilder,
      footerBuilder: (context, selectedItems) => DanbooruMultiSelectionActions(
        selectedPosts: selectedItems,
        endMultiSelect: () {
          _multiSelectController.disableMultiSelect();
        },
      ),
      multiSelectController: _multiSelectController,
      onLoadMore: widget.onLoadMore,
      onRefresh: widget.onRefresh,
      itemBuilder: (context, items, index) {
        final post = items[index];

        return ContextMenuRegion(
          isEnabled: !post.isBanned && !multiSelect,
          contextMenu: DanbooruPostContextMenu(
            hasAccount: authState is Authenticated,
            onMultiSelect: () {
              _multiSelectController.enableMultiSelect();
            },
            post: post,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => DanbooruImageGridItem(
              post: post,
              hideOverlay: false,
              autoScrollOptions: AutoScrollOptions(
                controller: _autoScrollController,
                index: index,
              ),
              onTap: !multiSelect
                  ? () {
                      goToDetailPage(
                        context: context,
                        posts: items,
                        initialIndex: index,
                        scrollController: _autoScrollController,
                      );
                    }
                  : null,
              enableFav: !multiSelect && authState is Authenticated,
              image: settings.imageListType == ImageListType.masonry
                  ? BooruImage(
                      aspectRatio: post.isBanned ? 0.8 : post.aspectRatio,
                      imageUrl: post.thumbnailFromSettings(settings),
                      borderRadius: BorderRadius.circular(
                        settings.imageBorderRadius,
                      ),
                      placeholderUrl: post.thumbnailImageUrl,
                      previewCacheManager:
                          ref.watch(previewImageCacheManagerProvider),
                      cacheHeight: (constraints.maxHeight * 2).toIntOrNull(),
                      cacheWidth: (constraints.maxWidth * 2).toIntOrNull(),
                    )
                  : BooruImageLegacy(
                      imageUrl: post.thumbnailFromSettings(settings),
                      placeholderUrl: post.thumbnailImageUrl,
                      borderRadius: BorderRadius.circular(
                        settings.imageBorderRadius,
                      ),
                      cacheHeight: (constraints.maxHeight * 2).toIntOrNull(),
                      cacheWidth: (constraints.maxWidth * 2).toIntOrNull(),
                    ),
            ),
          ),
        );
      },
      bodyBuilder: (context, itemBuilder, refreshing, data) {
        return SliverPostGrid(
          itemBuilder: itemBuilder,
          refreshing: refreshing,
          error: widget.errors,
          data: data,
          onRetry: () => widget.controller.refresh(),
        );
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class FavoriteGroupMultiSelectionActions extends ConsumerWidget {
  const FavoriteGroupMultiSelectionActions({
    super.key,
    required this.selectedPosts,
    required this.endMultiSelect,
    required this.onRemoveFromFavGroup,
  });

  final List<Post> selectedPosts;
  final void Function() endMultiSelect;
  final void Function() onRemoveFromFavGroup;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authenticationState = ref.watch(authenticationProvider);

    return ButtonBar(
      alignment: MainAxisAlignment.center,
      children: [
        DownloadProviderWidget(
          builder: (context, download) => IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () {
                    // ignore: prefer_foreach
                    for (final p in selectedPosts) {
                      download(p);
                    }

                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.download),
          ),
        ),
        if (authenticationState is Authenticated)
          IconButton(
            onPressed: selectedPosts.isNotEmpty
                ? () {
                    onRemoveFromFavGroup();
                    endMultiSelect();
                  }
                : null,
            icon: const Icon(Icons.remove),
          ),
      ],
    );
  }
}
