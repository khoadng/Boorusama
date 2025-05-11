// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../core/boorus/engine/engine.dart';
import '../../../../../core/boorus/engine/providers.dart';
import '../../../../../core/configs/ref.dart';
import '../../../../../core/foundation/clipboard.dart';
import '../../../../../core/foundation/url_launcher.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/posts/details/routes.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/posts/post/widgets.dart';
import '../../../../../core/posts/sources/source.dart';
import '../../../../../core/settings/providers.dart';
import '../../../../../core/settings/settings.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../post/post.dart';
import 'danbooru_post_context_menu.dart';

class DefaultDanbooruImageGridItem extends StatelessWidget {
  const DefaultDanbooruImageGridItem({
    required this.index,
    required this.multiSelectController,
    required this.autoScrollController,
    required this.controller,
    super.key,
    this.blockOverlay,
    this.contextMenu,
    this.onTap,
    this.useHero = true,
  });

  final int index;
  final MultiSelectController multiSelectController;
  final AutoScrollController autoScrollController;
  final PostGridController<DanbooruPost> controller;
  final BlockOverlayItem? blockOverlay;
  final Widget? contextMenu;
  final VoidCallback? onTap;
  final bool useHero;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: multiSelectController.multiSelectNotifier,
      builder: (_, multiSelect, __) => ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, __) {
          final post = posts[index];

          final artistTags = [...post.artistTags]..remove('banned_artist');

          return DefaultPostListContextMenuRegion(
            isEnabled: !multiSelect && !post.isBanned,
            contextMenu: contextMenu ??
                DanbooruPostContextMenu(
                  onMultiSelect: () {
                    multiSelectController.enableMultiSelect(
                      initialSelected: [post.id],
                    );
                  },
                  post: post,
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
                        builder: (_, ref, __) {
                          final booruRepo = ref.watch(currentBooruRepoProvider);
                          final gridThumbnailUrlBuilder =
                              booruRepo?.gridThumbnailUrlGenerator();

                          final imgUrl = gridThumbnailUrlBuilder != null
                              ? gridThumbnailUrlBuilder
                                  .generateThumbnailUrl(post)
                              : post.thumbnailImageUrl;
                          return SliverPostGridImageGridItem(
                            post: post,
                            multiSelectEnabled: multiSelect,
                            quickActionButton: Consumer(
                              builder: (_, ref, __) {
                                final config = ref.watchConfigAuth;

                                return !post.isBanned &&
                                        !multiSelect &&
                                        config.hasLoginDetails()
                                    ? DefaultImagePreviewQuickActionButton(
                                        post: post,
                                      )
                                    : const SizedBox.shrink();
                              },
                            ),
                            autoScrollOptions: AutoScrollOptions(
                              controller: autoScrollController,
                              index: index,
                            ),
                            onTap: onTap ??
                                (post.isBanned
                                    ? null
                                    : () {
                                        goToPostDetailsPageFromController(
                                          context: context,
                                          controller: controller,
                                          initialIndex: index,
                                          scrollController:
                                              autoScrollController,
                                          initialThumbnailUrl: imgUrl,
                                        );
                                      }),
                            image: _buildImage(post, imgUrl),
                            score: post.isBanned ? null : post.score,
                            blockOverlay: blockOverlay ??
                                (post.isBanned
                                    ? _buildBlockOverlayItem(
                                        post,
                                        artistTags,
                                        context,
                                      )
                                    : null),
                          );
                        },
                      );

                      return multiSelect
                          ? DefaultSelectableItem(
                              multiSelectController: multiSelectController,
                              index: index,
                              post: post,
                              item: item,
                            )
                          : item;
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

  BlockOverlayItem _buildBlockOverlayItem(
    DanbooruPost post,
    List<String> artistTags,
    BuildContext context,
  ) {
    return BlockOverlayItem(
      overlay: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                switch (post.source) {
                  final WebSource source => WebsiteLogo(
                      size: 18,
                      url: source.faviconUrl,
                    ),
                  _ => const SizedBox.shrink(),
                },
                const SizedBox(width: 4),
                const Text(
                  maxLines: 1,
                  'Banned post',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            if (artistTags.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: [
                    for (final tag in artistTags)
                      RawCompactChip(
                        label: Text(
                          tag.replaceAll('_', ' '),
                          maxLines: 1,
                          style: TextStyle(
                            color:
                                Theme.of(context).colorScheme.onErrorContainer,
                          ),
                        ),
                        backgroundColor:
                            Theme.of(context).colorScheme.errorContainer,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        onTap: () {
                          AppClipboard.copyAndToast(
                            context,
                            artistTags.join(' '),
                            message: 'Tag copied to clipboard',
                          );
                        },
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
      onTap: switch (post.source) {
        final WebSource source => () => launchExternalUrlString(source.url),
        _ => null,
      },
    );
  }

  Widget _buildImage(DanbooruPost post, String imgUrl) {
    return Consumer(
      builder: (_, ref, __) {
        final imageListType = ref.watch(
          imageListingSettingsProvider.select(
            (value) => value.imageListType,
          ),
        );

        final imageBorderRadius = ref.watch(
          imageListingSettingsProvider.select(
            (value) => value.imageBorderRadius,
          ),
        );

        return BooruImage(
          aspectRatio: post.isBanned ? 0.8 : post.aspectRatio,
          imageUrl: imgUrl,
          borderRadius: BorderRadius.circular(
            imageBorderRadius,
          ),
          forceCover: imageListType == ImageListType.standard,
          fit: imageListType == ImageListType.classic ? BoxFit.contain : null,
          placeholderUrl: post.thumbnailImageUrl,
          gaplessPlayback: true,
        );
      },
    );
  }
}
