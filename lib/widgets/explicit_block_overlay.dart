// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'conditional_parent_widget.dart';

class ExplicitContentBlockOverlay extends StatefulWidget {
  const ExplicitContentBlockOverlay({
    super.key,
    required this.block,
    required this.childBuilder,
    required this.width,
    required this.height,
  });

  final bool block;
  final Widget Function(bool block) childBuilder;
  final double width;
  final double height;

  @override
  State<ExplicitContentBlockOverlay> createState() =>
      _ExplicitContentBlockOverlayState();
}

class _ExplicitContentBlockOverlayState
    extends State<ExplicitContentBlockOverlay> {
  late bool block = widget.block;

  @override
  void didUpdateWidget(covariant ExplicitContentBlockOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.block != widget.block) {
      setState(() {
        block = widget.block;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return ConditionalParentWidget(
      condition: block,
      conditionalBuilder: (child) => Stack(
        children: [
          AbsorbPointer(child: child),
          Positioned.fill(
            child: SizedBox(
              width: widget.width,
              height: widget.height,
              child: ActionChip(
                side: BorderSide(
                  color: Theme.of(context).hintColor.withOpacity(0.1),
                ),
                label: Text(
                  'Explicit'.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                onPressed: () {
                  setState(() {
                    block = false;
                  });
                },
              ),
            ),
          ),
        ],
      ),
      child: widget.childBuilder(block),
    );
  }
}
