// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/feats/blacklists/blacklists.dart';
import 'package:boorusama/core/feats/boorus/boorus.dart';
import 'package:boorusama/core/feats/posts/posts.dart';
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/core/router.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/theme/theme.dart';
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
    this.safeArea = true,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final Widget Function(T post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;
  final bool safeArea;

  final PostGridController<T> controller;
  final bool refreshAtStart;

  final BooruError? errors;

  final Widget Function(
    List<T> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  ConsumerState<InfinitePostListScaffold<T>> createState() =>
      _InfinitePostListScaffoldState<T>();
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

    final config = ref.watchConfig;
    final booruBuilder = ref.watch(booruBuilderProvider);
    final favoriteAdder = booruBuilder?.favoriteAdder;
    final favoriteRemover = booruBuilder?.favoriteRemover;
    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;
    final canFavorite = booruBuilder?.canFavorite(config) ?? false;

    return LayoutBuilder(
      builder: (context, constraints) => PostGrid(
        controller: widget.controller,
        refreshAtStart: widget.refreshAtStart,
        scrollController: _autoScrollController,
        safeArea: widget.safeArea,
        sliverHeaderBuilder: (context) {
          return [
            ...widget.sliverHeaderBuilder?.call(context) ?? [],
            if (settings.imageListType == ImageListType.masonry &&
                config.booruType == BooruType.gelbooruV1)
              SliverToBoxAdapter(
                child: WarningContainer(
                    contentBuilder: (context) => Text(
                          'Consider switching to the "Standard" layout. "Masonry" is glitchy on Gelbooru V1.',
                          style: TextStyle(
                            color: context.colorScheme.onError,
                          ),
                        )),
              ),
          ];
        },
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
                isGif: post.isGif,
                isAI: post.isAI,
                onTap: !multiSelect
                    ? () {
                        goToPostDetailsPage(
                          context: context,
                          posts: items,
                          initialIndex: index,
                        );
                      }
                    : null,
                isFaved: ref.watch(favoriteProvider(post.id)),
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
                image: BooruImage(
                  aspectRatio: post.aspectRatio,
                  imageUrl: gridThumbnailUrlBuilder != null
                      ? gridThumbnailUrlBuilder(settings, post)
                      : post.thumbnailImageUrl,
                  borderRadius: BorderRadius.circular(
                    settings.imageBorderRadius,
                  ),
                  forceFill: settings.imageListType == ImageListType.standard,
                  placeholderUrl: post.thumbnailImageUrl,
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
