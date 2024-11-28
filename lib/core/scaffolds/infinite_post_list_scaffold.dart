// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/core/configs/configs.dart';
import 'package:boorusama/core/images/images.dart';
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/core/widgets/widgets.dart';
import 'package:boorusama/foundation/gestures.dart';
import 'package:boorusama/functional.dart';
import 'package:boorusama/router.dart';
import 'package:boorusama/widgets/widgets.dart';

class DefaultImageGridItem<T extends Post> extends ConsumerWidget {
  const DefaultImageGridItem({
    super.key,
    required this.index,
    required this.multiSelectController,
    required this.autoScrollController,
    required this.controller,
  });

  final int index;
  final MultiSelectController<T> multiSelectController;
  final AutoScrollController autoScrollController;
  final PostGridController<T> controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageListingSettingsProvider);
    final config = ref.watchConfig;
    final booruBuilder = ref.watchBooruBuilder(config);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = config.postGestures?.preview;
    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;

    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) => ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, __) {
          final post = posts[index];

          return DefaultPostListContextMenuRegion(
            isEnabled: !multiSelect,
            contextMenu: GeneralPostContextMenu(
              hasAccount: config.hasLoginDetails(),
              onMultiSelect: () {
                multiSelectController.enableMultiSelect();
              },
              post: post,
            ),
            gestures: gestures,
            child: ExplicitContentBlockOverlay(
              rating: post.rating,
              child: Builder(
                builder: (context) {
                  final item = GestureDetector(
                    onLongPress:
                        gestures.canLongPress && postGesturesHandler != null
                            ? () => postGesturesHandler(
                                  ref,
                                  gestures?.longPress,
                                  post,
                                )
                            : null,
                    child: SliverPostGridImageGridItem(
                      post: post,
                      hideOverlay: multiSelect,
                      onTap: !multiSelect
                          ? () {
                              if (gestures.canTap &&
                                  postGesturesHandler != null) {
                                postGesturesHandler(
                                  ref,
                                  ref.watchConfig.postGestures?.preview?.tap,
                                  post,
                                );
                              } else {
                                goToPostDetailsPageFromController(
                                  context: context,
                                  controller: controller,
                                  initialIndex: index,
                                  scrollController: autoScrollController,
                                );
                              }
                            }
                          : null,
                      quickActionButton: !multiSelect
                          ? DefaultImagePreviewQuickActionButton(post: post)
                          : null,
                      autoScrollOptions: AutoScrollOptions(
                        controller: autoScrollController,
                        index: index,
                      ),
                      score: post.score,
                      image: BooruImage(
                        aspectRatio: post.aspectRatio,
                        imageUrl: gridThumbnailUrlBuilder != null
                            ? gridThumbnailUrlBuilder(
                                settings.imageQuality,
                                post,
                              )
                            : post.thumbnailImageUrl,
                        borderRadius: BorderRadius.circular(
                          settings.imageBorderRadius,
                        ),
                        forceFill:
                            settings.imageListType == ImageListType.standard,
                        placeholderUrl: post.thumbnailImageUrl,
                      ),
                    ),
                  );

                  return multiSelect
                      ? ValueListenableBuilder(
                          valueListenable:
                              multiSelectController.selectedItemsNotifier,
                          builder: (_, selectedItems, __) => SelectableItem(
                            index: index,
                            isSelected: selectedItems.contains(post),
                            onTap: () =>
                                multiSelectController.toggleSelection(post),
                            itemBuilder: (context, isSelected) => item,
                          ),
                        )
                      : item;
                },
              ),
            ),
          );
        },
      ),
    );
  }
}

class SinglePagePostListScaffold<T extends Post>
    extends ConsumerStatefulWidget {
  const SinglePagePostListScaffold({
    super.key,
    required this.posts,
    this.sliverHeaders,
  });

  final List<T> posts;
  final List<Widget>? sliverHeaders;

  @override
  ConsumerState<SinglePagePostListScaffold<T>> createState() =>
      _SinglePagePostListScaffoldState<T>();
}

class _SinglePagePostListScaffoldState<T extends Post>
    extends ConsumerState<SinglePagePostListScaffold<T>> {
  @override
  Widget build(BuildContext context) {
    return CustomContextMenuOverlay(
      child: PostScope(
        fetcher: (page) => TaskEither.Do(
          ($) async => page == 1 ? widget.posts.toResult() : <T>[].toResult(),
        ),
        builder: (context, controller) => PostGrid(
          controller: controller,
          sliverHeaders: [
            if (widget.sliverHeaders != null) ...widget.sliverHeaders!,
          ],
        ),
      ),
    );
  }
}
