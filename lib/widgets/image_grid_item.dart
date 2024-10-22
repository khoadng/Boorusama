// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import 'package:boorusama/foundation/theme.dart';
import 'package:boorusama/widgets/widgets.dart';

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
    this.hideOverlay = false,
    this.duration,
    this.hasSound,
    this.score,
    this.isAI = false,
    this.isGif = false,
    this.quickActionButton,
    this.borderRadius,
  });

  final AutoScrollOptions? autoScrollOptions;
  final void Function()? onTap;
  final Widget image;

  final bool? isAnimated;
  final bool? hasComments;
  final bool? hasParentOrChildren;
  final bool? isTranslated;
  final bool hideOverlay;
  final double? duration;
  final bool? hasSound;
  final int? score;
  final bool isAI;
  final bool isGif;
  final Widget? quickActionButton;
  final BorderRadius? borderRadius;

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
          if (!hideOverlay)
            if (quickActionButton != null)
              Positioned(
                bottom: 4,
                right: 4,
                child: quickActionButton!,
              )
            else
              const SizedBox.shrink(),
          if (score != null)
            Positioned(
              bottom: 4,
              left: 4,
              child: Container(
                constraints: const BoxConstraints(minWidth: 28),
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                decoration: const BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.all(Radius.circular(8)),
                ),
                child: Text(
                  NumberFormat.compact().format(score),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: switch (score!) {
                      > 0 => context.colors.upvoteColor,
                      < 0 => context.colors.downvoteColor,
                      _ => Colors.white,
                    },
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOverlayIcon(BuildContext context) {
    return IgnorePointer(
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Wrap(
          spacing: 1,
          children: [
            if (isGif)
              const ImageOverlayIcon(
                icon: Symbols.gif,
              )
            else if (isAnimated ?? false)
              if (duration == null)
                const ImageOverlayIcon(
                  icon: Symbols.play_circle,
                  size: 20,
                )
              else
                VideoPlayDurationIcon(
                  duration: duration,
                  hasSound: hasSound,
                ),
            if (isTranslated ?? false)
              const ImageOverlayIcon(icon: Symbols.g_translate, size: 20),
            if (hasComments ?? false)
              const ImageOverlayIcon(icon: Symbols.comment, size: 20),
            if (hasParentOrChildren ?? false)
              const ImageOverlayIcon(icon: FontAwesomeIcons.images, size: 16),
            if (isAI)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                height: 25,
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: const BorderRadius.all(Radius.circular(4)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'AI',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    return Stack(
      children: [
        image,
        Padding(
          padding: const EdgeInsets.only(top: 1, left: 1),
          child: _buildOverlayIcon(context),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: ImageInkWellWithBorderOnFocus(
              onTap: onTap,
              borderRadius: borderRadius,
            ),
          ),
        ),
      ],
    );
  }
}

class ImageInkWellWithBorderOnFocus extends StatefulWidget {
  const ImageInkWellWithBorderOnFocus({
    super.key,
    this.onTap,
    this.borderRadius,
  });

  final void Function()? onTap;
  final BorderRadius? borderRadius;

  @override
  State<ImageInkWellWithBorderOnFocus> createState() =>
      _ImageInkWellWithBorderOnFocusState();
}

class _ImageInkWellWithBorderOnFocusState
    extends State<ImageInkWellWithBorderOnFocus> {
  var node = FocusNode();
  late final isFocused = ValueNotifier(node.hasFocus);
  @override
  void initState() {
    super.initState();
    node.addListener(_onFocusChange);
  }

  @override
  void dispose() {
    super.dispose();
    node.removeListener(_onFocusChange);
    node.dispose();
  }

  void _onFocusChange() {
    isFocused.value = node.hasFocus;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        ValueListenableBuilder(
          valueListenable: isFocused,
          builder: (context, focused, child) {
            return focused
                ? Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: widget.borderRadius ??
                            const BorderRadius.all(Radius.circular(8)),
                        border: Border.all(
                          color: context.colorScheme.primary,
                          width: 6,
                        ),
                      ),
                    ),
                  )
                : const SizedBox.shrink();
          },
        ),
        InkWell(
          focusNode: node,
          focusColor: context.colorScheme.primary.withOpacity(0.2),
          highlightColor: Colors.transparent,
          splashFactory: FasterInkSplash.splashFactory,
          splashColor: Colors.black38,
          onTap: widget.onTap,
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
                  maxHeight: MediaQuery.sizeOf(context).height * 0.8,
                  maxWidth: MediaQuery.sizeOf(context).width * 0.8,
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
