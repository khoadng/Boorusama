// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/boorus/core/feats/boorus/boorus.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/widgets/widgets.dart';

class InfinitePostListScaffold<T extends Post> extends ConsumerStatefulWidget {
  const InfinitePostListScaffold({
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
    required this.onPostTap,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final Widget Function(T post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;

  final PostGridController<T> controller;
  final bool refreshAtStart;

  final BooruError? errors;

  final Widget Function(
    List<T> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  final void Function(
    BuildContext context,
    List<T> posts,
    T post,
    AutoScrollController scrollController,
    Settings settings,
    int initialIndex,
  ) onPostTap;

  @override
  ConsumerState<InfinitePostListScaffold> createState() =>
      _InfinitePostListScaffoldState();
}

class _InfinitePostListScaffoldState<T extends Post>
    extends ConsumerState<InfinitePostListScaffold<T>> {
  late final AutoScrollController _autoScrollController;
  final _multiSelectController = MultiSelectController<T>();
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
    final settings = ref.watch(settingsProvider);
    final globalBlacklist = ref.watch(globalBlacklistedTagsProvider);

    final config = ref.watch(currentBooruConfigProvider);
    final booruBuilders = ref.watch(booruBuildersProvider);
    final favoriteAdder = booruBuilders[config.booruType]?.favoriteAdder;
    final favoriteRemover = booruBuilders[config.booruType]?.favoriteRemover;
    final favoriteChecker = booruBuilders[config.booruType]?.favoriteChecker;
    final isAuthenticated = config.hasLoginDetails();

    final canFavorite = favoriteAdder != null &&
        favoriteRemover != null &&
        favoriteChecker != null &&
        isAuthenticated;

    return LayoutBuilder(
      builder: (context, constraints) => PostGrid(
        controller: widget.controller,
        refreshAtStart: widget.refreshAtStart,
        scrollController: _autoScrollController,
        sliverHeaderBuilder: widget.sliverHeaderBuilder,
        footerBuilder: (context, selectedItems) =>
            widget.multiSelectActions != null
                ? widget.multiSelectActions!.call(
                    selectedItems,
                    () {
                      _multiSelectController.disableMultiSelect();
                    },
                  )
                : DefaultMultiSelectionActions(
                    selectedPosts: selectedItems,
                    endMultiSelect: () {
                      _multiSelectController.disableMultiSelect();
                    },
                  ),
        multiSelectController: _multiSelectController,
        onLoadMore: widget.onLoadMore,
        onRefresh: widget.onRefresh,
        blacklistedTags: {
          ...globalBlacklist.map((e) => e.name),
        },
        itemBuilder: (context, items, index) {
          final post = items[index];

          return ContextMenuRegion(
            isEnabled: !multiSelect,
            contextMenu: widget.contextMenuBuilder != null
                ? widget.contextMenuBuilder!.call(
                    post,
                    () {
                      _multiSelectController.enableMultiSelect();
                    },
                  )
                : GeneralPostContextMenu(
                    hasAccount: false,
                    onMultiSelect: () {
                      _multiSelectController.enableMultiSelect();
                    },
                    post: post,
                  ),
            child: LayoutBuilder(
              builder: (context, constraints) => ImageGridItem(
                isAI: post.isAI,
                onTap: !multiSelect
                    ? () {
                        widget.onPostTap.call(
                          context,
                          items,
                          post,
                          _autoScrollController,
                          settings,
                          index,
                        );
                      }
                    : null,
                isFaved: favoriteChecker?.call(post.id) ?? false,
                enableFav: !multiSelect && canFavorite,
                onFavToggle: (isFaved) async {
                  if (isFaved) {
                    if (favoriteAdder == null) return;
                    await favoriteAdder(post.id);
                  } else {
                    if (favoriteRemover == null) return;
                    await favoriteRemover(post.id);
                  }
                },
                autoScrollOptions: AutoScrollOptions(
                  controller: _autoScrollController,
                  index: index,
                ),
                isAnimated: post.isAnimated,
                isTranslated: post.isTranslated,
                hasComments: post.hasComment,
                hasParentOrChildren: post.hasParentOrChildren,
                score: settings.showScoresInGrid ? post.score : null,
                image: settings.imageListType == ImageListType.masonry
                    ? BooruImage(
                        aspectRatio: post.aspectRatio,
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
            constraints: constraints,
            itemBuilder: itemBuilder,
            refreshing: refreshing,
            error: widget.errors,
            data: data,
            onRetry: () => widget.controller.refresh(),
          );
        },
      ),
    );
  }
}
