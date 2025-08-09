// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';
import 'package:selection_mode/selection_mode.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/gesture/gesture.dart';
import '../../../../configs/ref.dart';
import '../../../../settings/providers.dart';
import '../../../../settings/settings.dart';
import '../../../post/post.dart';
import '../../../post/tags.dart';
import '../../../post/widgets.dart';

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
    required this.index,
    required this.quickActionButton,
    required this.autoScrollOptions,
    required this.onTap,
    required this.image,
    required this.score,
    required this.multiSelectEnabled,
    super.key,
    this.blockOverlay,
    this.leadingIcons,
  });

  final T post;
  final int index;
  final Widget? quickActionButton;
  final AutoScrollOptions? autoScrollOptions;
  final VoidCallback? onTap;
  final Widget image;
  final int? score;
  final BlockOverlayItem? blockOverlay;
  final bool multiSelectEnabled;
  final List<Widget>? leadingIcons;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final overlay = blockOverlay;
    final hideOverlay = multiSelectEnabled;

    final booruBuilder = ref.watch(booruBuilderProvider(ref.watchConfigAuth));
    final postGesturesHandler = booruBuilder?.postGestureHandlerBuilder;
    final gestures = ref.watchPostGestures?.preview;

    final imageBorderRadius = ref.watch(
      imageListingSettingsProvider.select(
        (value) => value.imageBorderRadius,
      ),
    );

    final showScoresInGrid = ref.watch(
      imageListingSettingsProvider.select(
        (value) => value.showScoresInGrid,
      ),
    );

    final scoreWidget = showScoresInGrid
        ? score.toOption().fold(
            () => null,
            (s) => ImageScoreWidget(score: s),
          )
        : null;

    final imageListType = ref.watch(
      imageListingSettingsProvider.select((v) => v.imageListType),
    );

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
            leadingIcons: leadingIcons,
            borderRadius: BorderRadius.circular(imageBorderRadius),
            isGif: post.isGif,
            isAI: post.isAI,
            hideOverlay: hideOverlay,
            quickActionButton: quickActionButton,
            autoScrollOptions: autoScrollOptions,
            splashColor: multiSelectEnabled ? Colors.transparent : null,
            onTap: multiSelectEnabled
                ? () {
                    SelectionMode.of(context).toggleItem(index);
                  }
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
            scoreWidget: scoreWidget ?? const SizedBox.shrink(),
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
            if (imageListType == ImageListType.masonry)
              Positioned.fill(
                child: Center(
                  child: overlay.overlay,
                ),
              )
            else
              Align(
                alignment: Alignment.center,
                child: overlay.overlay,
              ),
          ],
        ],
      ),
    );
  }
}
