// Flutter imports:
import 'package:boorusama/core/ui/post_grid.dart';
import 'package:boorusama/core/ui/post_grid_controller.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/danbooru/application/favorites/favorite_post_cubit.dart';
import 'package:boorusama/boorus/danbooru/domain/posts.dart';
import 'package:boorusama/boorus/danbooru/router.dart';
import 'package:boorusama/boorus/danbooru/ui/posts.dart';
import 'package:boorusama/core/application/authentication.dart';
import 'package:boorusama/core/application/settings.dart';
import 'package:boorusama/core/domain/posts.dart';
import 'package:boorusama/core/domain/posts/post.dart';
import 'package:boorusama/core/domain/settings.dart';
import 'package:boorusama/core/infra/preloader/preloader.dart';
import 'package:boorusama/core/ui/booru_image.dart';
import 'package:boorusama/core/ui/booru_image_legacy.dart';
import 'package:boorusama/core/ui/download_provider_widget.dart';
import 'package:boorusama/core/ui/image_grid_item.dart';
import 'package:boorusama/core/ui/multi_select_controller.dart';
import 'package:boorusama/core/ui/sliver_post_grid.dart';
import 'package:boorusama/core/utils.dart';
import 'package:boorusama/utils/double_utils.dart';

class DanbooruInfinitePostList2 extends StatefulWidget {
  const DanbooruInfinitePostList2({
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
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget> Function(BuildContext context)? sliverHeaderBuilder;
  final AutoScrollController? scrollController;
  final Widget Function(Post post, void Function() next)? contextMenuBuilder;

  final bool extendBody;
  final double? extendBodyHeight;

  final Widget Function(
    List<Post> selectedPosts,
    void Function() endMultiSelect,
  )? multiSelectActions;

  final PostGridController<DanbooruPost> controller;

  @override
  State<DanbooruInfinitePostList2> createState() =>
      _DanbooruInfinitePostListState();
}

class _DanbooruInfinitePostListState extends State<DanbooruInfinitePostList2> {
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
    final authState =
        context.select((AuthenticationCubit cubit) => cubit.state);

    return BlocBuilder<SettingsCubit, SettingsState>(
      buildWhen: (previous, current) =>
          previous.settings.imageBorderRadius !=
              current.settings.imageBorderRadius ||
          previous.settings.imageGridSpacing !=
              current.settings.imageGridSpacing ||
          previous.settings.imageQuality != current.settings.imageQuality ||
          previous.settings.imageListType != current.settings.imageListType,
      builder: (context, state) {
        return BlocBuilder<FavoritePostCubit, FavoritePostState>(
          buildWhen: (previous, current) => current is FavoritePostListSuccess,
          builder: (context, favoriteState) {
            return PostGrid(
              controller: widget.controller,
              scrollController: _autoScrollController,
              sliverHeaderBuilder: widget.sliverHeaderBuilder,
              footerBuilder: (context, selectedItems) =>
                  DanbooruMultiSelectionActions(
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

                var isFaved = false;
                if (favoriteState is FavoritePostListSuccess) {
                  isFaved = favoriteState.favorites[post.id] ?? false;
                }

                return ContextMenuRegion(
                  isEnabled: !multiSelect,
                  contextMenu: DanbooruPostContextMenu(
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
                              goToDetailPage(
                                context: context,
                                posts: items,
                                initialIndex: index,
                                scrollController: _autoScrollController,
                              );
                            }
                          : null,
                      isFaved: isFaved,
                      enableFav: authState is Authenticated,
                      onFavToggle: (isFaved) async {
                        final favoritePostCubit =
                            context.read<FavoritePostCubit>();
                        if (!isFaved) {
                          await favoritePostCubit.removeFavorite(post.id);
                        } else {
                          await favoritePostCubit.addFavorite(post.id);
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
                      image:
                          state.settings.imageListType == ImageListType.masonry
                              ? BooruImage(
                                  aspectRatio: post.aspectRatio,
                                  imageUrl: getImageUrlForDisplay(
                                    post,
                                    getImageQuality(
                                      size: state.settings.gridSize,
                                      presetImageQuality:
                                          state.settings.imageQuality,
                                    ),
                                  ),
                                  borderRadius: BorderRadius.circular(
                                    state.settings.imageBorderRadius,
                                  ),
                                  placeholderUrl: post.thumbnailImageUrl,
                                  previewCacheManager:
                                      context.read<PreviewImageCacheManager>(),
                                  cacheHeight:
                                      (constraints.maxHeight * 2).toIntOrNull(),
                                  cacheWidth:
                                      (constraints.maxWidth * 2).toIntOrNull(),
                                )
                              : BooruImageLegacy(
                                  imageUrl: getImageUrlForDisplay(
                                    post,
                                    getImageQuality(
                                      size: state.settings.gridSize,
                                      presetImageQuality:
                                          state.settings.imageQuality,
                                    ),
                                  ),
                                  placeholderUrl: post.thumbnailImageUrl,
                                  borderRadius: BorderRadius.circular(
                                    state.settings.imageBorderRadius,
                                  ),
                                  cacheHeight:
                                      (constraints.maxHeight * 2).toIntOrNull(),
                                  cacheWidth:
                                      (constraints.maxWidth * 2).toIntOrNull(),
                                ),
                    ),
                  ),
                );
              },
              bodyBuilder: (context, itemBuilder, refreshing, data) {
                return SliverPostGrid(
                  itemBuilder: itemBuilder,
                  settings: state.settings,
                  refreshing: refreshing,
                  error: null, //FIXME: error handling
                  data: data,
                );
              },
            );
          },
        );
      },
    );
  }
}

// ignore: prefer-single-widget-per-file
class FavoriteGroupMultiSelectionActions extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final authenticationState =
        context.select((AuthenticationCubit cubit) => cubit.state);

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
