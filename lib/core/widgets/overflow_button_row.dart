import 'package:flutter/material.dart';

class OverflowButtonRow extends StatefulWidget {
  const OverflowButtonRow({
    required this.children,
    super.key,
    this.onOverflow,
    this.buttonWidth,
    this.spacing = 8.0,
    this.overflowIcon,
  });

  final List<Widget> children;
  final ValueChanged<int>? onOverflow;
  final double? buttonWidth;
  final double spacing;
  final Widget? overflowIcon;

  @override
  State<OverflowButtonRow> createState() => _OverflowButtonRowState();
}

class _OverflowButtonRowState extends State<OverflowButtonRow> {
  @override
  Widget build(BuildContext context) {
    if (widget.children.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveButtonWidth =
            widget.buttonWidth ??
            (constraints.maxWidth / widget.children.length).clamp(80.0, 150.0);

        final maxButtons =
            ((constraints.maxWidth + widget.spacing) /
                    (effectiveButtonWidth + widget.spacing))
                .floor();

        if (widget.children.length <= maxButtons) {
          return _buildRow(widget.children, effectiveButtonWidth);
        }

        final visibleCount = maxButtons - 1;
        final visibleChildren = widget.children.take(visibleCount).toList();
        final overflowChildren = widget.children.skip(visibleCount).toList();

        return _buildRow([
          ...visibleChildren,
          _buildOverflowButton(overflowChildren, effectiveButtonWidth),
        ], effectiveButtonWidth);
      },
    );
  }

  Widget _buildRow(List<Widget> widgets, double width) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widgets
          .asMap()
          .entries
          .map(
            (entry) => [
              SizedBox(width: width, child: entry.value),
              if (entry.key < widgets.length - 1)
                SizedBox(width: widget.spacing),
            ],
          )
          .expand((e) => e)
          .toList(),
    );
  }

  Widget _buildOverflowButton(List<Widget> overflowChildren, double width) {
    return MenuAnchor(
      builder: (context, controller, child) => IconButton(
        icon: widget.overflowIcon ?? const Icon(Icons.more_horiz),
        onPressed: () {
          controller.isOpen ? controller.close() : controller.open();
        },
      ),
      menuChildren: overflowChildren
          .asMap()
          .entries
          .map(
            (entry) => MenuItemButton(
              onPressed: () => widget.onOverflow?.call(
                entry.key + (widget.children.length - overflowChildren.length),
              ),
              child: IgnorePointer(
                child: SizedBox(
                  width: width,
                  child: entry.value,
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}
