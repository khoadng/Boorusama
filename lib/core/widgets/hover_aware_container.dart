// Flutter imports:
import 'package:flutter/material.dart';

class HoverAwareContainer extends StatefulWidget {
  const HoverAwareContainer({
    super.key,
    this.borderRadius,
    required this.child,
  });

  final Widget child;
  final BorderRadius? borderRadius;

  @override
  State<HoverAwareContainer> createState() => _HoverAwareContainerState();
}

class _HoverAwareContainerState extends State<HoverAwareContainer> {
  var isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: isHovered
              ? Theme.of(context).colorScheme.surfaceContainer
              : Colors.transparent,
          borderRadius: widget.borderRadius ?? BorderRadius.circular(6),
        ),
        child: widget.child,
      ),
    );
  }
}
