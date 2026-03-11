// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:i18n/i18n.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../../core/config_widgets/website_logo.dart';
import '../../../../../core/configs/config/providers.dart';
import '../../../../../core/images/booru_image.dart';
import '../../../../../core/posts/details/routes.dart';
import '../../../../../core/posts/listing/providers.dart';
import '../../../../../core/posts/listing/types.dart';
import '../../../../../core/posts/listing/widgets.dart';
import '../../../../../core/posts/post/widgets.dart';
import '../../../../../core/posts/sources/types.dart';
import '../../../../../core/settings/providers.dart';
import '../../../../../core/widgets/widgets.dart';
import '../../../../../foundation/clipboard.dart';
import '../../../../../foundation/url_launcher.dart';
import '../../post/types.dart';
import 'danbooru_post_preview.dart';

const _kBannedTextThreshold = 200.0;

class DefaultDanbooruImageGridItem extends StatelessWidget {
  const DefaultDanbooruImageGridItem({
    required this.index,
    required this.autoScrollController,
    required this.controller,
    super.key,
    this.blockOverlay,
    this.onTap,
    this.useHero = true,
    this.quickActionButton,
  });

  final int index;
  final AutoScrollController autoScrollController;
  final PostGridController<DanbooruPost> controller;
  final BlockOverlayItem? blockOverlay;
  final VoidCallback? onTap;
  final bool useHero;
  final Widget? quickActionButton;

  @override
  Widget build(BuildContext context) {
    final selectionModeController = SelectionMode.of(context);

    return ListenableBuilder(
      listenable: selectionModeController,
      builder: (_, _) => ValueListenableBuilder(
        valueListenable: controller.itemsNotifier,
        builder: (_, posts, _) {
          final post = posts[index];
          final multiSelect = selectionModeController.isActive;

          final artistTags = [...post.artistTags]..remove('banned_artist');

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

                        final gridThumbnailSettings = ref.watch(
                          gridThumbnailSettingsProvider(config),
                        );

                        final imgUrl = gridThumbnailUrlBuilder.generateUrl(
                          post,
                          settings: gridThumbnailSettings,
                        );
                        return SliverPostGridImageGridItem(
                          post: post,
                          index: index,
                          multiSelectEnabled: multiSelect,
                          quickActionButton:
                              quickActionButton ??
                              (!post.isBanned && !multiSelect
                                  ? DefaultImagePreviewQuickActionButton(
                                      post: post,
                                    )
                                  : const SizedBox.shrink()),
                          autoScrollOptions: AutoScrollOptions(
                            controller: autoScrollController,
                            index: index,
                          ),
                          onTap:
                              onTap ??
                              (post.isBanned
                                  ? null
                                  : () {
                                      goToPostDetailsPageFromController(
                                        ref: ref,
                                        controller: controller,
                                        initialIndex: index,
                                        scrollController: autoScrollController,
                                        initialThumbnailUrl: imgUrl,
                                      );
                                    }),
                          image: _buildImage(post, imgUrl),
                          score: post.isBanned ? null : post.score,
                          blockOverlay:
                              blockOverlay ??
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

                    return Consumer(
                      builder: (_, ref, _) => DanbooruTagListPrevewTooltip(
                        post: post,
                        child: DefaultSelectableItem(
                          index: index,
                          post: post,
                          item: item,
                          config: ref.watchConfigAuth,
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
                  final WebSource source => ConfigAwareWebsiteLogo(
                    size: 18,
                    url: source.url,
                  ),
                  _ => const SizedBox.shrink(),
                },
                const SizedBox(width: 4),
                ConstrainedBox(
                  constraints: const BoxConstraints(
                    maxWidth: _kBannedTextThreshold,
                  ),
                  child: LayoutBuilder(
                    builder: (context, constraints) =>
                        constraints.maxWidth > _kBannedTextThreshold
                        ? Text(
                            maxLines: 1,
                            'Banned post'.hc,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : const SizedBox.shrink(),
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
                            color: Theme.of(
                              context,
                            ).colorScheme.onErrorContainer,
                          ),
                        ),
                        backgroundColor: Theme.of(
                          context,
                        ).colorScheme.errorContainer,
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
      builder: (_, ref, _) {
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
          config: ref.watchConfigAuth,
          aspectRatio: post.isBanned ? 0.8 : post.aspectRatio,
          imageUrl: imgUrl,
          borderRadius: BorderRadius.circular(
            imageBorderRadius,
          ),
          forceCover: imageListType == ImageListType.standard,
          fit: imageListType == ImageListType.classic ? BoxFit.contain : null,
          placeholderUrl: post.thumbnailImageUrl,
        );
      },
    );
  }
}
