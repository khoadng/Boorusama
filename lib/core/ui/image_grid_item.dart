// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/core.dart';
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'booru_image.dart';

class AutoScrollOptions {
  const AutoScrollOptions({
    required this.controller,
    required this.index,
  });

  final AutoScrollController controller;
  final int index;
}

class ImageGridItem extends StatelessWidget {
  const ImageGridItem({
    super.key,
    required this.borderRadius,
    required this.gridSize,
    this.onTap,
    required this.imageQuality,
    this.isAnimated,
    this.hasComments,
    this.hasParentOrChildren,
    this.isTranslated,
    required this.previewUrl,
    required this.previewPlaceholderUrl,
    this.autoScrollOptions,
    required this.aspectRatio,
    this.image,
    this.cacheHeight,
    this.cacheWidth,
    this.enableFav = false,
    this.onFavToggle,
    this.isFaved,
    this.previewCacheManager,
    this.multiSelect = false,
    this.multiSelectBuilder,
  });

  final AutoScrollOptions? autoScrollOptions;
  final void Function()? onTap;
  final GridSize gridSize;
  final BorderRadius? borderRadius;
  final ImageQuality imageQuality;
  final double aspectRatio;
  final Widget? image;
  final int? cacheWidth;
  final int? cacheHeight;

  final bool? isAnimated;
  final bool? hasComments;
  final bool? hasParentOrChildren;
  final bool? isTranslated;
  final String previewUrl;
  final String previewPlaceholderUrl;
  final bool enableFav;
  final void Function(bool value)? onFavToggle;
  final bool? isFaved;
  final CacheManager? previewCacheManager;
  final bool multiSelect;
  final Widget Function()? multiSelectBuilder;

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: autoScrollOptions != null,
      conditionalBuilder: (child) => AutoScrollTag(
        index: autoScrollOptions!.index,
        controller: autoScrollOptions!.controller,
        key: ValueKey(autoScrollOptions!.index),
        child: child,
      ),
      child: Stack(
        children: [
          _buildImage(context),
          if (enableFav && !multiSelect)
            Positioned(
              bottom: 4,
              right: 4,
              child: Container(
                padding: const EdgeInsets.only(
                  top: 2,
                  bottom: 1,
                  right: 1,
                  left: 3,
                ),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.black.withOpacity(0.5),
                ),
                child: LikeButton(
                  isLiked: isFaved,
                  onTap: (isLiked) {
                    onFavToggle?.call(!isLiked);

                    return Future.value(!isLiked);
                  },
                  likeBuilder: (bool isLiked) {
                    return Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border_outlined,
                      color: isLiked ? Colors.redAccent : Colors.white,
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlayIcon() {
    return IgnorePointer(
      child: Wrap(
        spacing: 1,
        children: [
          if (isAnimated ?? false)
            const _OverlayIcon(icon: Icons.play_circle_outline, size: 20),
          if (isTranslated ?? false)
            const _OverlayIcon(icon: Icons.g_translate_outlined, size: 20),
          if (hasComments ?? false)
            const _OverlayIcon(icon: Icons.comment, size: 20),
          if (hasParentOrChildren ?? false)
            const _OverlayIcon(icon: FontAwesomeIcons.images, size: 16),
        ],
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final imageItem = image ??
        BooruImage(
          aspectRatio: aspectRatio,
          imageUrl: previewUrl,
          placeholderUrl: previewPlaceholderUrl,
          borderRadius: borderRadius,
          previewCacheManager: previewCacheManager,
          cacheHeight: cacheHeight,
          cacheWidth: cacheWidth,
        );

    return !multiSelect
        ? Stack(
            children: [
              GestureDetector(
                onTap: onTap,
                child: imageItem,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 1, left: 1),
                child: _buildOverlayIcon(),
              ),
            ],
          )
        : Stack(
            children: [
              imageItem,
              // multiSelectBackgroundBuilder?.call() ?? const SizedBox.shrink(),
              multiSelectBuilder?.call() ?? const SizedBox.shrink(),
            ],
          );
  }
}

// ignore: prefer-single-widget-per-file
class QuickPreviewImage extends StatelessWidget {
  const QuickPreviewImage({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.of(context).pop(),
      child: CallbackShortcuts(
        bindings: {
          const SingleActivator(LogicalKeyboardKey.escape): () =>
              Navigator.of(context).pop(),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: const Color.fromARGB(189, 0, 0, 0),
            body: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxHeight: MediaQuery.of(context).size.height * 0.8,
                  maxWidth: MediaQuery.of(context).size.width * 0.8,
                ),
                child: child,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _OverlayIcon extends StatelessWidget {
  const _OverlayIcon({
    required this.icon,
    this.size,
  });

  final IconData icon;
  final double? size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 25,
      height: 25,
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: const BorderRadius.all(Radius.circular(4)),
      ),
      child: Icon(
        icon,
        color: Colors.white70,
        size: size,
      ),
    );
  }
}
