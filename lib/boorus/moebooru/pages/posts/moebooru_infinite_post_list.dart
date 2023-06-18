// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/core/feats/authentication/authentication.dart';
import 'package:boorusama/boorus/core/feats/posts/posts.dart';
import 'package:boorusama/boorus/core/feats/settings/settings.dart';
import 'package:boorusama/boorus/core/provider.dart';
import 'package:boorusama/boorus/core/widgets/widgets.dart';
import 'package:boorusama/boorus/moebooru/router.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/widgets/widgets.dart';

class MoebooruInfinitePostList extends ConsumerStatefulWidget {
  const MoebooruInfinitePostList({
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

  final PostGridController<Post> controller;
  final bool refreshAtStart;

  final bool extendBody;
  final double? extendBodyHeight;

  final BooruError? errors;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  ConsumerState<MoebooruInfinitePostList> createState() =>
      _MoebooruInfinitePostListState();
}

class _MoebooruInfinitePostListState
    extends ConsumerState<MoebooruInfinitePostList> {
  late final AutoScrollController _autoScrollController;
  final _multiSelectController = MultiSelectController<Post>();
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
      controller: widget.controller,
      scrollController: _autoScrollController,
      sliverHeaderBuilder: widget.sliverHeaderBuilder,
      footerBuilder: (context, selectedItems) => DefaultMultiSelectionActions(
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
          isEnabled: !multiSelect,
          contextMenu: GeneralPostContextMenu(
            hasAccount: false,
            onMultiSelect: () {
              _multiSelectController.enableMultiSelect();
            },
            post: post,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) => ImageGridItem(
              onTap: !multiSelect
                  ? () {
                      goToMoebooruDetailsPage(
                        context: context,
                        posts: items,
                        initialPage: index,
                        scrollController: _autoScrollController,
                      );
                    }
                  : null,
              isFaved: false,
              enableFav: authState.isAuthenticated,
              onFavToggle: (isFaved) async {},
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
