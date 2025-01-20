// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../boorus/engine/engine.dart';
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/ref.dart';
import '../../../../images/booru_image.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';
import '../../../details/routes.dart';
import '../../../post/post.dart';
import '../../../post/widgets.dart';
import '../widgets/default_post_list_context_menu_region.dart';
import '../widgets/general_post_context_menu.dart';
import '../widgets/post_grid_controller.dart';
import '../widgets/sliver_post_grid_image_grid_item.dart';

class DefaultImageGridItem<T extends Post> extends ConsumerWidget {
  const DefaultImageGridItem({
    required this.index,
    required this.multiSelectController,
    required this.autoScrollController,
    required this.controller,
    required this.useHero,
    super.key,
  });

  final int index;
  final MultiSelectController<T> multiSelectController;
  final AutoScrollController autoScrollController;
  final PostGridController<T> controller;
  final bool useHero;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) => ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, __) {
          final post = posts[index];

          return DefaultPostListContextMenuRegion(
            isEnabled: !multiSelect,
            contextMenu: GeneralPostContextMenu(
              hasAccount: ref.watchConfigAuth.hasLoginDetails(),
              onMultiSelect: () {
                multiSelectController.enableMultiSelect();
              },
              post: post,
            ),
            child: ExplicitContentBlockOverlay(
              rating: post.rating,
              child: Builder(
                builder: (context) {
                  final item = SliverPostGridImageGridItem(
                    post: post,
                    multiSelectEnabled: multiSelect,
                    onTap: () {
                      goToPostDetailsPageFromController(
                        context: context,
                        controller: controller,
                        initialIndex: index,
                        scrollController: autoScrollController,
                      );
                    },
                    quickActionButton: !multiSelect
                        ? DefaultImagePreviewQuickActionButton(post: post)
                        : null,
                    autoScrollOptions: AutoScrollOptions(
                      controller: autoScrollController,
                      index: index,
                    ),
                    score: post.score,
                    image: BooruHero(
                      tag: useHero ? '${post.id}_hero' : null,
                      child: _Image(post: post),
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

class _Image<T extends Post> extends ConsumerWidget {
  const _Image({
    required this.post,
    super.key,
  });

  final T post;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final gridThumbnailUrlBuilder = booruBuilder?.gridThumbnailUrlBuilder;
    final imageQuality = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageQuality),
    );
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageBorderRadius),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageListType),
    );

    return BooruImage(
      aspectRatio: post.aspectRatio,
      imageUrl: gridThumbnailUrlBuilder != null
          ? gridThumbnailUrlBuilder(
              imageQuality,
              post,
            )
          : post.thumbnailImageUrl,
      borderRadius: BorderRadius.circular(
        imageBorderRadius,
      ),
      forceFill: imageListType == ImageListType.standard,
      placeholderUrl: post.thumbnailImageUrl,
      gaplessPlayback: true,
    );
  }
}
