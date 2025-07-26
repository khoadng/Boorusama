// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:i18n/i18n.dart';

const double _kMinButtonWidth = 80;
const double _kMaxButtonWidth = 150;
const double _kDefaultSpacing = 8;
const double _kWrapSpacing = 4;
const double _kMenuAlignmentOffsetY = 12;

enum OverflowStrategy {
  /// Dropdown menu
  menu,

  /// Multi-row wrapping
  wrap,

  /// Centers if fits, scrolls if overflow
  scrollable,
}

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
           icon: Icon(icon),
           onPressed: onPressed,
           tooltip: tooltip ?? title,
         ),
         onTap: onPressed,
       );
}

class AdaptiveButtonRow extends StatefulWidget {
  const AdaptiveButtonRow._({
    required this.buttons,
    required this.overflowStrategy,
    this.buttonWidth,
    this.spacing = _kDefaultSpacing,
    this.overflowIcon,
    this.overflowButtonBuilder,
    this.onOverflow,
    this.scrollController,
    this.runSpacing = _kDefaultSpacing,
    this.alignment = WrapAlignment.center,
    super.key,
  });

  factory AdaptiveButtonRow.menu({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    Widget? overflowIcon,
    Widget Function(VoidCallback)? overflowButtonBuilder,
    ValueChanged<int>? onOverflow,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.menu,
    buttonWidth: buttonWidth,
    spacing: spacing,
    overflowIcon: overflowIcon,
    overflowButtonBuilder: overflowButtonBuilder,
    onOverflow: onOverflow,
    key: key,
  );

  factory AdaptiveButtonRow.scrollable({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    ScrollController? scrollController,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.scrollable,
    buttonWidth: buttonWidth,
    spacing: spacing,
    scrollController: scrollController,
    key: key,
  );

  factory AdaptiveButtonRow.wrap({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kWrapSpacing,
    double runSpacing = _kWrapSpacing,
    WrapAlignment alignment = WrapAlignment.center,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.wrap,
    buttonWidth: buttonWidth,
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    key: key,
  );

  final List<ButtonData> buttons;
  final OverflowStrategy overflowStrategy;
  final double? buttonWidth;
  final double spacing;

  // Menu-specific
  final Widget? overflowIcon;
  final Widget Function(VoidCallback onPressed)? overflowButtonBuilder;
  final ValueChanged<int>? onOverflow;

  // Scroll-specific
  final ScrollController? scrollController;

  // Wrap-specific
  final double runSpacing;
  final WrapAlignment alignment;

  @override
  State<AdaptiveButtonRow> createState() => _AdaptiveButtonRowState();
}

class _AdaptiveButtonRowState extends State<AdaptiveButtonRow> {
  @override
  Widget build(BuildContext context) {
    if (widget.buttons.isEmpty) return const SizedBox.shrink();

    return switch (widget.overflowStrategy) {
      OverflowStrategy.menu => _buildMenuLayout(),
      OverflowStrategy.scrollable => _buildScrollableLayout(),
      OverflowStrategy.wrap => _buildWrapLayout(),
    };
  }

  Widget _buildMenuLayout() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final effectiveButtonWidth =
            widget.buttonWidth ??
            (constraints.maxWidth / widget.buttons.length).clamp(
              _kMinButtonWidth,
              _kMaxButtonWidth,
            );

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
          return _buildRow(alwaysVisible, effectiveButtonWidth);
        }

        final visibleSecondary = secondary.take(availableSpace).toList();
        final remainingSpace = availableSpace - visibleSecondary.length;

        if (remainingSpace <= 0) {
          return _buildRow(
            [
              ...alwaysVisible,
              ...visibleSecondary,
            ],
            effectiveButtonWidth,
          );
        }

        if (canOverflow.length <= remainingSpace) {
          return _buildRow(
            [
              ...alwaysVisible,
              ...visibleSecondary,
              ...canOverflow,
            ],
            effectiveButtonWidth,
          );
        }

        final visibleOverflowable = canOverflow
            .take(remainingSpace - 1)
            .toList();
        final overflowButtons = canOverflow.skip(remainingSpace - 1).toList();

        return _buildRow(
          [
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
              title: 'More'.hc,
            ),
          ],
          effectiveButtonWidth,
        );
      },
    );
  }

  Widget _buildScrollableLayout() {
    final length = widget.buttons.length;
    final effectiveButtonWidth = widget.buttonWidth ?? _kMinButtonWidth;
    final requiredWidth =
        (effectiveButtonWidth * length) + (widget.spacing * (length - 1));

    return LayoutBuilder(
      builder: (context, constraints) {
        return switch (requiredWidth <= constraints.maxWidth) {
          // If content fits, use centered row
          true => Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: _buildButtonWidgets(),
          ),
          // Otherwise, use horizontal scroll
          false => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.scrollController,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              controller: widget.scrollController,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: _buildButtonWidgets(),
              ),
            ),
          ),
        };
      },
    );
  }

  Widget _buildWrapLayout() {
    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      alignment: widget.alignment,
      children: _buildButtonWidgets(),
    );
  }

  List<Widget> _buildButtonWidgets() {
    final effectiveButtonWidth = widget.buttonWidth;

    return widget.buttons
        .asMap()
        .entries
        .map(
          (entry) => [
            if (effectiveButtonWidth != null)
              SizedBox(
                width: effectiveButtonWidth,
                child: entry.value.widget,
              )
            else
              entry.value.widget,
            if (entry.key < widget.buttons.length - 1)
              SizedBox(width: widget.spacing),
          ],
        )
        .expand((e) => e)
        .toList();
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
              SizedBox(
                width: width,
                child: entry.value.widget,
              ),
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
      consumeOutsideTap: true,
      alignmentOffset: const Offset(0, _kMenuAlignmentOffsetY),
      style: MenuStyle(
        padding: WidgetStateProperty.all(
          const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 8,
          ),
        ),
      ),
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
