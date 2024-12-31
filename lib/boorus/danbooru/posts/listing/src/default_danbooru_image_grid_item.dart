// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../../core/boorus/engine/engine.dart';
import '../../../../../core/boorus/engine/providers.dart';
import '../../../../../core/configs/config.dart';
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

class DefaultDanbooruImageGridItem extends ConsumerWidget {
  const DefaultDanbooruImageGridItem({
    required this.index,
    required this.multiSelectController,
    required this.autoScrollController,
    required this.controller,
    super.key,
    this.blockOverlay,
    this.contextMenu,
    this.onTap,
  });

  final int index;
  final MultiSelectController<DanbooruPost> multiSelectController;
  final AutoScrollController autoScrollController;
  final PostGridController<DanbooruPost> controller;
  final BlockOverlayItem? blockOverlay;
  final Widget? contextMenu;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(imageListingSettingsProvider);
    final config = ref.watchConfigAuth;
    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = ref.watchPostGestures?.preview;

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
                      quickActionButton: !post.isBanned &&
                              !multiSelect &&
                              config.hasLoginDetails()
                          ? DefaultImagePreviewQuickActionButton(post: post)
                          : null,
                      autoScrollOptions: AutoScrollOptions(
                        controller: autoScrollController,
                        index: index,
                      ),
                      onTap: multiSelect
                          ? null
                          : onTap ??
                              (post.isBanned
                                  ? null
                                  : () {
                                      if (gestures.canTap &&
                                          postGesturesHandler != null) {
                                        postGesturesHandler(
                                          ref,
                                          gestures?.tap,
                                          post,
                                        );
                                      } else {
                                        goToPostDetailsPageFromController(
                                          context: context,
                                          controller: controller,
                                          initialIndex: index,
                                          scrollController:
                                              autoScrollController,
                                        );
                                      }
                                    }),
                      image: BooruImage(
                        aspectRatio: post.isBanned ? 0.8 : post.aspectRatio,
                        imageUrl: post
                            .thumbnailFromImageQuality(settings.imageQuality),
                        borderRadius: BorderRadius.circular(
                          settings.imageBorderRadius,
                        ),
                        forceFill:
                            settings.imageListType == ImageListType.standard,
                        placeholderUrl: post.thumbnailImageUrl,
                      ),
                      score: post.isBanned ? null : post.score,
                      blockOverlay: blockOverlay ??
                          (post.isBanned
                              ? BlockOverlayItem(
                                  overlay: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: switch (post.source) {
                                              final WebSource source =>
                                                WebsiteLogo(
                                                  url: source.faviconUrl,
                                                ),
                                              _ => const SizedBox.shrink(),
                                            },
                                          ),
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
                                          ),
                                          child: Wrap(
                                            children: [
                                              for (final tag in artistTags)
                                                ActionChip(
                                                  visualDensity:
                                                      VisualDensity.compact,
                                                  label: Text(
                                                    tag.replaceAll('_', ' '),
                                                    maxLines: 1,
                                                    style: TextStyle(
                                                      color: Theme.of(context)
                                                          .colorScheme
                                                          .onErrorContainer,
                                                    ),
                                                  ),
                                                  backgroundColor:
                                                      Theme.of(context)
                                                          .colorScheme
                                                          .errorContainer,
                                                  onPressed: () {
                                                    AppClipboard.copyAndToast(
                                                      context,
                                                      artistTags.join(' '),
                                                      message:
                                                          'Tag copied to clipboard',
                                                    );
                                                  },
                                                ),
                                            ],
                                          ),
                                        ),
                                    ],
                                  ),
                                  onTap: switch (post.source) {
                                    final WebSource source => () =>
                                        launchExternalUrlString(source.url),
                                    _ => null,
                                  },
                                )
                              : null),
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
