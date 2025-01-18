// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:context_menus/context_menus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../boorus/engine/providers.dart';
import '../../../configs/config.dart';
import '../../../configs/ref.dart';
import '../../../settings/providers.dart';
import '../../post/post.dart';
import '../../post/tags.dart';
import '../../post/widgets.dart';
import 'post_grid_controller.dart';
import 'sliver_raw_post_grid.dart';

class SliverPostGrid<T extends Post> extends ConsumerWidget {
  const SliverPostGrid({
    required this.constraints,
    required this.itemBuilder,
    required this.postController,
    super.key,
  });

  final BoxConstraints? constraints;
  final IndexedWidgetBuilder itemBuilder;
  final PostGridController<T> postController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageGridPadding = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridPadding),
    );
    final imageListType = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageListType),
    );
    final gridSize = ref
        .watch(imageListingSettingsProvider.select((value) => value.gridSize));
    final imageGridSpacing = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageGridSpacing),
    );
    final imageGridAspectRatio = ref.watch(
      imageListingSettingsProvider
          .select((value) => value.imageGridAspectRatio),
    );
    final postsPerPage = ref.watch(
      imageListingSettingsProvider.select((value) => value.postsPerPage),
    );

    return SliverRawPostGrid(
      constraints: constraints,
      itemBuilder: itemBuilder,
      postController: postController,
      padding: EdgeInsets.symmetric(
        horizontal: imageGridPadding,
      ),
      listType: imageListType,
      size: gridSize,
      spacing: imageGridSpacing,
      aspectRatio: imageGridAspectRatio,
      postsPerPage: postsPerPage,
    );
  }
}

class BlockOverlayItem {
  const BlockOverlayItem({
    required this.overlay,
    this.onTap,
  });

  final VoidCallback? onTap;
  final Widget overlay;
}

class SliverPostGridImageGridItem<T extends Post> extends ConsumerWidget {
  const SliverPostGridImageGridItem({
    required this.post,
    required this.quickActionButton,
    required this.autoScrollOptions,
    required this.onTap,
    required this.image,
    required this.score,
    required this.multiSelectEnabled,
    super.key,
    this.blockOverlay,
  });

  final T post;
  final Widget? quickActionButton;
  final AutoScrollOptions? autoScrollOptions;
  final VoidCallback? onTap;
  final Widget image;
  final int? score;
  final BlockOverlayItem? blockOverlay;
  final bool multiSelectEnabled;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select((value) => value.imageBorderRadius),
    );
    final showScoresInGrid = ref.watch(
      imageListingSettingsProvider.select((value) => value.showScoresInGrid),
    );

    final overlay = blockOverlay;
    final hideOverlay = multiSelectEnabled;

    final booruBuilder = ref.watch(currentBooruBuilderProvider);
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = ref.watchPostGestures?.preview;

    return GestureDetector(
      onLongPress: gestures.canLongPress && postGesturesHandler != null
          ? () => postGesturesHandler(
                ref,
                gestures?.longPress,
                post,
              )
          : null,
      child: Stack(
        children: [
          ImageGridItem(
            borderRadius: BorderRadius.circular(imageBorderRadius),
            isGif: post.isGif,
            isAI: post.isAI,
            hideOverlay: hideOverlay,
            quickActionButton: quickActionButton,
            autoScrollOptions: autoScrollOptions,
            onTap: multiSelectEnabled
                ? null
                : () {
                    if (gestures.canTap && postGesturesHandler != null) {
                      postGesturesHandler(
                        ref,
                        gestures?.tap,
                        post,
                      );
                    } else {
                      onTap?.call();
                    }
                  },
            image: image,
            isAnimated: post.isAnimated,
            isTranslated: post.isTranslated,
            hasComments: post.hasComment,
            hasParentOrChildren: post.hasParentOrChildren,
            hasSound: post.hasSound,
            duration: post.duration,
            score: showScoresInGrid ? score : null,
          ),
          if (overlay != null) ...[
            Positioned.fill(
              child: InkWell(
                highlightColor: Colors.transparent,
                splashFactory: FasterInkSplash.splashFactory,
                splashColor: Colors.black38,
                onTap: blockOverlay?.onTap,
              ),
            ),
            Positioned.fill(
              child: Center(
                child: overlay.overlay,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class DefaultPostListContextMenuRegion extends ConsumerWidget {
  const DefaultPostListContextMenuRegion({
    required this.contextMenu,
    required this.child,
    super.key,
    this.isEnabled = true,
  });

  final bool isEnabled;
  final Widget contextMenu;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gestures = ref.watchPostGestures?.preview;

    if (gestures.canLongPress) return child;

    return ContextMenuRegion(
      isEnabled: isEnabled,
      contextMenu: contextMenu,
      child: child,
    );
  }
}
