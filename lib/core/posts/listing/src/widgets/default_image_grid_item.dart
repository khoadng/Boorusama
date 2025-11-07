// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../configs/config/providers.dart';
import '../../../../configs/config/types.dart';
import '../../../../images/booru_image.dart';
import '../../../../settings/providers.dart';
import '../../../../widgets/widgets.dart';
import '../../../details/routes.dart';
import '../../../post/types.dart';
import '../../../post/widgets.dart';
import '../../widgets.dart';
import '../providers/providers.dart';
import '../types/image_list_type.dart';
import 'post_grid_controller.dart';

class DefaultImageGridItem<T extends Post> extends StatelessWidget {
  const DefaultImageGridItem({
    required this.index,
    required this.autoScrollController,
    required this.controller,
    required this.useHero,
    required this.config,
    this.onTap,
    super.key,
    this.leadingIcons,
    this.imageUrl,
    this.imageCacheManager,
  });

  final int index;
  final AutoScrollController autoScrollController;
  final PostGridController<T> controller;
  final bool useHero;
  final VoidCallback? onTap;
  final List<Widget>? leadingIcons;
  final String? imageUrl;
  final ImageCacheManager? imageCacheManager;
  final BooruConfigAuth config;

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
          return HeroMode(
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

                    return Consumer(
                      builder: (_, ref, _) => DefaultTagListPrevewTooltip(
                        post: post,
                        config: config,
                        child: DefaultSelectableItem(
                          index: index,
                          post: post,
                          item: item,
                          indicatorSize: ref.watch(
                            selectionIndicatorSizeProvider,
                          ),
                        ),
                      ),
                    );
                  },
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
      config: ref.watchConfigAuth,
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
