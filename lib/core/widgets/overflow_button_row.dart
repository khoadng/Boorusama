import 'package:flutter/material.dart';

enum ButtonBehavior {
  /// Can overflow to menu
  normal,

  /// Always in main row
  alwaysVisible,

  /// Disappears when no space
  secondary,
}

class ButtonData {
  const ButtonData({
    required this.widget,
    required this.title,
    this.onTap,
    this.behavior = ButtonBehavior.normal,
  });

  final Widget widget;
  final String title;
  final VoidCallback? onTap;
  final ButtonBehavior behavior;
}

class SimpleButtonData extends ButtonData {
  SimpleButtonData({
    required IconData icon,
    required super.title,
    required VoidCallback onPressed,
    String? tooltip,
    super.behavior,
  }) : super(
         widget: IconButton(
           splashRadius: 16,
           icon: Icon(icon),
           onPressed: onPressed,
           tooltip: tooltip ?? title,
         ),
         onTap: onPressed,
       );
}

class OverflowButtonRow extends StatefulWidget {
  const OverflowButtonRow({
    required this.buttons,
    super.key,
    this.onOverflow,
    this.buttonWidth,
    this.spacing = 8.0,
    this.overflowIcon,
    this.overflowButtonBuilder,
  });

  final List<ButtonData> buttons;
  final ValueChanged<int>? onOverflow;
  final double? buttonWidth;
  final double spacing;
  final Widget? overflowIcon;
  final Widget Function(VoidCallback onPressed)? overflowButtonBuilder;

  @override
  State<OverflowButtonRow> createState() => _OverflowButtonRowState();
}

class _OverflowButtonRowState extends State<OverflowButtonRow> {
  @override
  Widget build(BuildContext context) {
    if (widget.buttons.isEmpty) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveButtonWidth =
            widget.buttonWidth ??
            (constraints.maxWidth / widget.buttons.length).clamp(80.0, 150.0);

        final maxButtons =
            ((constraints.maxWidth + widget.spacing) /
                    (effectiveButtonWidth + widget.spacing))
                .floor();

        final alwaysVisible = widget.buttons
            .where((b) => b.behavior == ButtonBehavior.alwaysVisible)
            .toList();
        final canOverflow = widget.buttons
            .where((b) => b.behavior == ButtonBehavior.normal)
            .toList();
        final secondary = widget.buttons
            .where((b) => b.behavior == ButtonBehavior.secondary)
            .toList();

        final availableSpace = maxButtons - alwaysVisible.length;

        assert(
          alwaysVisible.length <= maxButtons,
          'Too many alwaysVisible buttons (${alwaysVisible.length}) for available space ($maxButtons)',
        );

        if (availableSpace <= 0) {
          // Only show always visible buttons
          return _buildRow(alwaysVisible, effectiveButtonWidth);
        }

        final visibleSecondary = secondary.take(availableSpace).toList();
        final remainingSpace = availableSpace - visibleSecondary.length;

        if (remainingSpace <= 0) {
          // Show always visible + some secondary
          return _buildRow([
            ...alwaysVisible,
            ...visibleSecondary,
          ], effectiveButtonWidth);
        }

        if (canOverflow.length <= remainingSpace) {
          // All buttons fit
          return _buildRow([
            ...alwaysVisible,
            ...visibleSecondary,
            ...canOverflow,
          ], effectiveButtonWidth);
        }

        // Need overflow menu
        final visibleOverflowable = canOverflow
            .take(remainingSpace - 1)
            .toList();
        final overflowButtons = canOverflow.skip(remainingSpace - 1).toList();

        return _buildRow([
          ...alwaysVisible,
          ...visibleSecondary,
          ...visibleOverflowable,
          ButtonData(
            widget: _buildOverflowButton(
              overflowButtons,
              alwaysVisible.length +
                  visibleSecondary.length +
                  visibleOverflowable.length,
            ),
            title: 'More',
          ),
        ], effectiveButtonWidth);
      },
    );
  }

  Widget _buildRow(List<ButtonData> buttons, double width) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: buttons
          .asMap()
          .entries
          .map(
            (entry) => [
              SizedBox(width: width, child: entry.value.widget),
              if (entry.key < buttons.length - 1)
                SizedBox(width: widget.spacing),
            ],
          )
          .expand((e) => e)
          .toList(),
    );
  }

  Widget _buildOverflowButton(
    List<ButtonData> overflowButtons,
    int visibleCount,
  ) {
    return MenuAnchor(
      builder: (context, controller, child) =>
          widget.overflowButtonBuilder?.call(() {
            controller.isOpen ? controller.close() : controller.open();
          }) ??
          IconButton(
            icon: widget.overflowIcon ?? const Icon(Icons.more_horiz),
            onPressed: () {
              controller.isOpen ? controller.close() : controller.open();
            },
          ),
      menuChildren: overflowButtons
          .asMap()
          .entries
          .map(
            (entry) => MenuItemButton(
              onPressed: () {
                final globalIndex = entry.key + visibleCount;
                if (entry.value.onTap != null) {
                  entry.value.onTap!();
                } else {
                  widget.onOverflow?.call(globalIndex);
                }
              },
              child: Text(entry.value.title),
            ),
          )
          .toList(),
    );
  }
}
