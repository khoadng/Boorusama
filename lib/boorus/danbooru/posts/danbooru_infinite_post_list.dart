// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/posts/posts.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/foundation/error.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/foundation/image.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class DanbooruInfinitePostList extends ConsumerStatefulWidget {
  const DanbooruInfinitePostList({
    super.key,
    this.onLoadMore,
    this.onRefresh,
    this.sliverHeaders,
    this.scrollController,
    this.extendBody = false,
    this.extendBodyHeight,
    required this.controller,
    this.refreshAtStart = true,
    this.errors,
    this.safeArea = true,
  });

  final VoidCallback? onLoadMore;
  final void Function()? onRefresh;
  final List<Widget>? sliverHeaders;
  final AutoScrollController? scrollController;

  final bool extendBody;
  final double? extendBodyHeight;
  final bool safeArea;

  final bool refreshAtStart;

  final BooruError? errors;

  final PostGridController<DanbooruPost> controller;

  @override
  ConsumerState<DanbooruInfinitePostList> createState() =>
      _DanbooruInfinitePostListState();
}

class _DanbooruInfinitePostListState
    extends ConsumerState<DanbooruInfinitePostList> {
  late final AutoScrollController _autoScrollController;
  final _multiSelectController = MultiSelectController<DanbooruPost>();

  @override
  void initState() {
    super.initState();
    _autoScrollController = widget.scrollController ?? AutoScrollController();
  }

  @override
  void dispose() {
    super.dispose();
    _multiSelectController.dispose();

    if (widget.scrollController == null) {
      _autoScrollController.dispose();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(imageListingSettingsProvider);

    final booruConfig = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(booruConfig);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final canHandleLongPress = booruBuilder?.canHandlePostGesture(
          GestureType.longPress,
          booruConfig.postGestures?.preview,
        ) ??
        false;

    return LayoutBuilder(
      builder: (context, constraints) => PostGrid(
        refreshAtStart: widget.refreshAtStart,
        controller: widget.controller,
        scrollController: _autoScrollController,
        sliverHeaders: widget.sliverHeaders,
        safeArea: widget.safeArea,
        footer: ValueListenableBuilder(
          valueListenable: _multiSelectController.selectedItemsNotifier,
          builder: (_, selectedItems, __) => DanbooruMultiSelectionActions(
            selectedPosts: selectedItems,
            endMultiSelect: () {
              _multiSelectController.disableMultiSelect();
            },
          ),
        ),
        multiSelectController: _multiSelectController,
        onLoadMore: widget.onLoadMore,
        onRefresh: widget.onRefresh,
        body: SliverPostGrid(
          postController: widget.controller,
          constraints: constraints,
          multiSelectController: _multiSelectController,
          itemBuilder: (context, index, post) {
            final (width, height, cacheWidth, cacheHeight) =
                context.sizeFromConstraints(
              constraints,
              post.aspectRatio,
            );

            return ConditionalParentWidget(
              condition: !canHandleLongPress,
              conditionalBuilder: (child) => ValueListenableBuilder(
                valueListenable: _multiSelectController.multiSelectNotifier,
                builder: (_, multiSelect, __) => ContextMenuRegion(
                  isEnabled: !post.isBanned && !multiSelect,
                  contextMenu: DanbooruPostContextMenu(
                    hasAccount: booruConfig.hasLoginDetails(),
                    onMultiSelect: () {
                      _multiSelectController.enableMultiSelect();
                    },
                    post: post,
                  ),
                  child: child,
                ),
              ),
              child: ConditionalParentWidget(
                condition: canHandleLongPress,
                conditionalBuilder: (child) => GestureDetector(
                  onLongPress: () {
                    if (postGesturesHandler != null) {
                      postGesturesHandler(
                        ref,
                        ref.watchConfig.postGestures?.preview?.longPress,
                        post,
                      );
                    }
                  },
                  child: child,
                ),
                child: ValueListenableBuilder(
                  valueListenable: _multiSelectController.multiSelectNotifier,
                  builder: (_, multiSelect, __) => ExplicitContentBlockOverlay(
                    block: settings.blurExplicitMedia && post.isExplicit,
                    width: width ?? 100,
                    height: height ?? 100,
                    childBuilder: (block) => DanbooruImageGridItem(
                      ignoreBanOverlay: block,
                      post: post,
                      hideOverlay: multiSelect,
                      autoScrollOptions: AutoScrollOptions(
                        controller: _autoScrollController,
                        index: index,
                      ),
                      onTap: !multiSelect
                          ? () {
                              if (booruBuilder?.canHandlePostGesture(
                                          GestureType.tap,
                                          booruConfig.postGestures?.preview) ==
                                      true &&
                                  postGesturesHandler != null) {
                                postGesturesHandler(
                                  ref,
                                  ref.watchConfig.postGestures?.preview?.tap,
                                  post,
                                );
                              } else {
                                goToPostDetailsPage(
                                  context: context,
                                  posts: widget.controller.items,
                                  initialIndex: index,
                                  scrollController: _autoScrollController,
                                );
                              }
                            }
                          : null,
                      enableFav: !multiSelect &&
                          booruConfig.hasLoginDetails() &&
                          !block,
                      image: BooruImage(
                        aspectRatio: post.isBanned ? 0.8 : post.aspectRatio,
                        imageUrl: block
                            ? ''
                            : post.thumbnailFromImageQuality(
                                settings.imageQuality),
                        borderRadius: BorderRadius.circular(
                          settings.imageBorderRadius,
                        ),
                        forceFill:
                            settings.imageListType == ImageListType.standard,
                        placeholderUrl: post.thumbnailImageUrl,
                        width: width,
                        height: height,
                        cacheHeight: cacheHeight,
                        cacheWidth: cacheWidth,
                        // null, // Will cause error sometimes, disabled for now
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
          error: widget.errors,
        ),
      ),
    );
  }
}
