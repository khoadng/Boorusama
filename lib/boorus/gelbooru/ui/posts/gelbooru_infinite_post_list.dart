// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/gelbooru/router.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/domain/error.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/provider.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_image_legacy.dart';
import 'package:boorusama/core/ui/default_multi_selection_actions.dart';
import 'package:boorusama/core/ui/general_post_context_menu.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/multi_select_controller.dart';
import 'package:boorusama/core/ui/post_grid.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:boorusama/core/ui/sliver_post_grid.dart';
import 'package:boorusama/utils/double_utils.dart';

class GelbooruInfinitePostList extends ConsumerStatefulWidget {
  const GelbooruInfinitePostList({
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

  final PostGridController<Post> controller;
  final bool refreshAtStart;

  final BooruError? errors;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  @override
  ConsumerState<GelbooruInfinitePostList> createState() =>
      _DanbooruInfinitePostListState();
}

class _DanbooruInfinitePostListState
    extends ConsumerState<GelbooruInfinitePostList> {
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
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);
    final settings = ref.watch(settingsProvider);

    return PostGrid(
      controller: widget.controller,
      refreshAtStart: widget.refreshAtStart,
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
                      goToGelbooruPostDetailsPage(
                        context: context,
                        posts: items,
                        initialIndex: index,
                        scrollController: _autoScrollController,
                      );
                    }
                  : null,
              isFaved: false,
              enableFav: authState is Authenticated,
              onFavToggle: (isFaved) async {},
              autoScrollOptions: AutoScrollOptions(
                controller: _autoScrollController,
                index: index,
              ),
              isAnimated: post.isAnimated,
              isTranslated: post.isTranslated,
              hasComments: post.hasComment,
              hasParentOrChildren: post.hasParentOrChildren,
              image: settings.imageListType == ImageListType.masonry
                  ? BooruImage(
                      aspectRatio: post.aspectRatio,
                      imageUrl: post.thumbnailFromSettings(settings),
                      borderRadius: BorderRadius.circular(
                        settings.imageBorderRadius,
                      ),
                      placeholderUrl: post.thumbnailImageUrl,
                      previewCacheManager:
                          context.read<PreviewImageCacheManager>(),
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
        );
      },
    );
  }
}
