// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:foundation/foundation.dart';
import 'package:foundation/widgets.dart';

// Project imports:
import '../../../../boorus/engine/providers.dart';
import '../../../../configs/gesture/gesture.dart';
import '../../../../configs/ref.dart';
import '../../../../settings/providers.dart';
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
          Consumer(
            builder: (_, ref, _) {
              final imageBorderRadius = ref.watch(
                imageListingSettingsProvider.select(
                  (value) => value.imageBorderRadius,
                ),
              );

              return ImageGridItem(
                leadingIcons: leadingIcons,
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
                scoreWidget: Consumer(
                  builder: (_, ref, _) {
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

                    return scoreWidget ?? const SizedBox.shrink();
                  },
                ),
              );
            },
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
