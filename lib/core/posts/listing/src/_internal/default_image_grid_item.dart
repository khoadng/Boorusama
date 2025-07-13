// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:extended_image/extended_image.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../boorus/engine/engine.dart';
import '../../../../configs/ref.dart';
import '../../../../images/booru_image.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../../widgets/widgets.dart';
import '../../../details/routes.dart';
import '../../../post/post.dart';
import '../../../post/widgets.dart';
import '../providers/providers.dart';
import '../widgets/default_post_list_context_menu_region.dart';
import '../widgets/default_selectable_item.dart';
import '../widgets/general_post_context_menu.dart';
import '../widgets/post_grid_controller.dart';
import '../widgets/sliver_post_grid_image_grid_item.dart';

class DefaultImageGridItem<T extends Post> extends StatelessWidget {
  const DefaultImageGridItem({
    required this.index,
    required this.autoScrollController,
    required this.controller,
    required this.useHero,
    this.onTap,
    super.key,
    this.contextMenu,
    this.leadingIcons,
    this.imageUrl,
    this.imageCacheManager,
  });

  final int index;
  final AutoScrollController autoScrollController;
  final PostGridController<T> controller;
  final bool useHero;
  final VoidCallback? onTap;
  final Widget? contextMenu;
  final List<Widget>? leadingIcons;
  final String? imageUrl;
  final ImageCacheManager? imageCacheManager;

  @override
  Widget build(BuildContext context) {
    final selectionModeController = SelectionMode.of(context);

    return ListenableBuilder(
      listenable: selectionModeController,
      builder: (context, _) => ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, _) {
          final multiSelect = selectionModeController.isActive;
          final post = posts[index];
          return DefaultPostListContextMenuRegion(
            isEnabled: !multiSelect,
            contextMenu:
                contextMenu ??
                Consumer(
                  builder: (_, ref, _) => GeneralPostContextMenu(
                    hasAccount: ref.watchConfigAuth.hasLoginDetails(),
                    onMultiSelect: () {
                      selectionModeController.enable(
                        initialSelected: [index],
                      );
                    },
                    post: post,
                  ),
                ),
            child: HeroMode(
              enabled: useHero,
              child: BooruHero(
                tag: '${post.id}_hero',
                child: ExplicitContentBlockOverlay(
                  rating: post.rating,
                  child: Builder(
                    builder: (context) {
                      final item = Consumer(
                        builder: (_, ref, _) {
                          final config = ref.watchConfigAuth;

                          final gridThumbnailUrlBuilder = ref.watch(
                            gridThumbnailUrlGeneratorProvider(config),
                          );

                          final imgUrl =
                              imageUrl ??
                              gridThumbnailUrlBuilder.generateUrl(
                                post,
                                settings: ref.watch(
                                  gridThumbnailSettingsProvider(config),
                                ),
                              );

                          return SliverPostGridImageGridItem(
                            post: post,
                            index: index,
                            multiSelectEnabled: multiSelect,
                            onTap:
                                onTap ??
                                () {
                                  goToPostDetailsPageFromController(
                                    ref: ref,
                                    controller: controller,
                                    initialIndex: index,
                                    scrollController: autoScrollController,
                                    initialThumbnailUrl: imgUrl,
                                  );
                                },
                            quickActionButton: !multiSelect
                                ? DefaultImagePreviewQuickActionButton(
                                    post: post,
                                  )
                                : null,
                            autoScrollOptions: AutoScrollOptions(
                              controller: autoScrollController,
                              index: index,
                            ),
                            score: post.score,
                            image: _Image(
                              post: post,
                              imageUrl: imgUrl,
                              imageCacheManager: imageCacheManager,
                            ),
                            leadingIcons: leadingIcons,
                          );
                        },
                      );

                      return DefaultSelectableItem(
                        index: index,
                        post: post,
                        item: item,
                      );
                    },
                  ),
                ),
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
    required this.imageUrl,
    super.key,
    this.imageCacheManager,
  });

  final T post;
  final String imageUrl;
  final ImageCacheManager? imageCacheManager;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageBorderRadius),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageListType),
    );

    return BooruImage(
      aspectRatio: post.aspectRatio,
      imageUrl: imageUrl,
      borderRadius: BorderRadius.circular(
        imageBorderRadius,
      ),
      forceCover: imageListType == ImageListType.standard,
      fit: imageListType == ImageListType.classic ? BoxFit.contain : null,
      placeholderUrl: post.thumbnailImageUrl,
      imageCacheManager: imageCacheManager,
    );
  }
}
