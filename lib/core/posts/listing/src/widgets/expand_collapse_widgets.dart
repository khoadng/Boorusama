// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

void collapseAndScrollBack(BuildContext context, VoidCallback setCollapsed) {
  final scrollable = Scrollable.maybeOf(context);
  final scrollPosition = scrollable?.position;
  final renderObj = context.findRenderObject();

  double? targetOffset;
  if (scrollPosition != null && renderObj is RenderBox) {
    final viewport = RenderAbstractViewport.of(renderObj);
    final revealOffset = viewport.getOffsetToReveal(renderObj, 0).offset.clamp(
      scrollPosition.minScrollExtent,
      scrollPosition.maxScrollExtent,
    );

    // Only scroll back if the item's top is above the current viewport
    if (revealOffset < scrollPosition.pixels) {
      targetOffset = revealOffset;
    }
  }

  setCollapsed();

  if (targetOffset != null && scrollPosition != null) {
    scrollPosition.jumpTo(targetOffset);
  }
}

class ExpandOverlay extends StatelessWidget {
  const ExpandOverlay({
    required this.color,
    required this.hintColor,
    required this.height,
    required this.onTap,
    super.key,
  });

  final Color color;
  final Color hintColor;
  final double height;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        height: height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              stops: const [0.0, 0.4, 1.0],
              colors: [
                color.withValues(alpha: 0),
                color.withValues(alpha: 0.8),
                color,
              ],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Icon(
                  Icons.expand_more,
                  size: 20,
                  color: hintColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CollapseButton extends StatelessWidget {
  const CollapseButton({
    required this.color,
    required this.onTap,
    super.key,
  });

  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Center(
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 4,
              ),
              child: Icon(
                Icons.expand_less,
                size: 20,
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
