// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:like_button/like_button.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/core/ui/widgets/conditional_parent_widget.dart';
import 'package:boorusama/utils/time_utils.dart';

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
    this.onTap,
    this.isAnimated,
    this.hasComments,
    this.hasParentOrChildren,
    this.isTranslated,
    this.autoScrollOptions,
    required this.image,
    this.enableFav = false,
    this.onFavToggle,
    this.isFaved,
    this.hideOverlay = false,
    this.duration,
    this.hasSound = false,
  });

  final AutoScrollOptions? autoScrollOptions;
  final void Function()? onTap;
  final Widget image;

  final bool? isAnimated;
  final bool? hasComments;
  final bool? hasParentOrChildren;
  final bool? isTranslated;
  final bool enableFav;
  final void Function(bool value)? onFavToggle;
  final bool? isFaved;
  final bool hideOverlay;
  final double? duration;
  final bool hasSound;

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
          if ((enableFav) && !hideOverlay)
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
            if (duration == null)
              const _OverlayIcon(icon: Icons.play_circle_outline, size: 20)
            else
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                        formatDurationForMedia(
                            Duration(seconds: duration!.round())),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        )),
                    hasSound
                        ? const Icon(
                            Icons.volume_up_rounded,
                            color: Colors.white70,
                            size: 18,
                          )
                        : const Icon(
                            Icons.volume_off_rounded,
                            color: Colors.white70,
                            size: 18,
                          ),
                  ],
                ),
              ),
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
    return Stack(
      children: [
        GestureDetector(
          onTap: onTap,
          child: image,
        ),
        if (!hideOverlay)
          Padding(
            padding: const EdgeInsets.only(top: 1, left: 1),
            child: _buildOverlayIcon(),
          ),
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
