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

enum ButtonPlacement {
  /// Main row if space, else menu
  flexible,

  /// Main row if space, else disappear
  hideOnOverflow,

  /// Always in menu
  menuOnly,
}

class ButtonData {
  const ButtonData({
    required this.widget,
    required this.title,
    this.onTap,
    this.required = false,
    this.placement = ButtonPlacement.flexible,
  });

  final Widget widget;
  final String title;
  final VoidCallback? onTap;
  final bool required;
  final ButtonPlacement placement;
}

class SimpleButtonData extends ButtonData {
  SimpleButtonData({
    required IconData icon,
    required super.title,
    required VoidCallback onPressed,
    String? tooltip,
    super.required,
    super.placement,
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
    this.maxVisibleButtons,
    super.key,
  });

  factory AdaptiveButtonRow.menu({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    Widget? overflowIcon,
    Widget Function(VoidCallback)? overflowButtonBuilder,
    ValueChanged<int>? onOverflow,
    int? maxVisibleButtons,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.menu,
    buttonWidth: buttonWidth,
    spacing: spacing,
    overflowIcon: overflowIcon,
    overflowButtonBuilder: overflowButtonBuilder,
    onOverflow: onOverflow,
    maxVisibleButtons: maxVisibleButtons,
    key: key,
  );

  factory AdaptiveButtonRow.scrollable({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    ScrollController? scrollController,
    int? maxVisibleButtons,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.scrollable,
    buttonWidth: buttonWidth,
    spacing: spacing,
    scrollController: scrollController,
    maxVisibleButtons: maxVisibleButtons,
    key: key,
  );

  factory AdaptiveButtonRow.wrap({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kWrapSpacing,
    double runSpacing = _kWrapSpacing,
    WrapAlignment alignment = WrapAlignment.center,
    int? maxVisibleButtons,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.wrap,
    buttonWidth: buttonWidth,
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    maxVisibleButtons: maxVisibleButtons,
    key: key,
  );

  final List<ButtonData> buttons;
  final OverflowStrategy overflowStrategy;
  final double? buttonWidth;
  final double spacing;
  final int? maxVisibleButtons;

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

  Widget _buildRowWithOptionalOverflow(
    List<ButtonData> mainButtons,
    List<ButtonData> overflowButtons,
    double buttonWidth,
  ) {
    if (overflowButtons.isEmpty) {
      return _buildRow(mainButtons, buttonWidth);
    }

    return _buildRow([
      ...mainButtons,
      ButtonData(
        widget: _buildOverflowButton(overflowButtons, mainButtons.length),
        title: 'More'.hc,
      ),
    ], buttonWidth);
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

        final spaceBasedMaxButtons =
            ((constraints.maxWidth + widget.spacing) /
                    (effectiveButtonWidth + widget.spacing))
                .floor();

        final maxButtons = widget.maxVisibleButtons != null
            ? widget.maxVisibleButtons!.clamp(1, spaceBasedMaxButtons)
            : spaceBasedMaxButtons;

        final requiredButtons = widget.buttons
            .where((b) => b.required)
            .toList();
        final optionalFlexibleButtons = widget.buttons
            .where(
              (b) => !b.required && b.placement == ButtonPlacement.flexible,
            )
            .toList();
        final optionalHideButtons = widget.buttons
            .where(
              (b) =>
                  !b.required && b.placement == ButtonPlacement.hideOnOverflow,
            )
            .toList();
        final menuOnlyButtons = widget.buttons
            .where((b) => b.placement == ButtonPlacement.menuOnly)
            .toList();

        final hasMenuOnlyButtons = menuOnlyButtons.isNotEmpty;
        final effectiveMaxButtons = hasMenuOnlyButtons
            ? maxButtons - 1
            : maxButtons;

        assert(
          requiredButtons.length <= effectiveMaxButtons,
          'Too many required buttons (${requiredButtons.length}) for max visible buttons ($effectiveMaxButtons)',
        );

        final availableSpace = effectiveMaxButtons - requiredButtons.length;

        if (availableSpace <= 0) {
          return _buildRowWithOptionalOverflow(
            requiredButtons,
            hasMenuOnlyButtons ? menuOnlyButtons : [],
            effectiveButtonWidth,
          );
        }

        final visibleHideButtons = optionalHideButtons
            .take(availableSpace)
            .toList();
        final remainingSpace = availableSpace - visibleHideButtons.length;

        if (remainingSpace <= 0) {
          return _buildRow(
            [
              ...requiredButtons,
              ...visibleHideButtons,
            ],
            effectiveButtonWidth,
          );
        }

        if (optionalFlexibleButtons.length <= remainingSpace) {
          return _buildRowWithOptionalOverflow(
            [
              ...requiredButtons,
              ...visibleHideButtons,
              ...optionalFlexibleButtons,
            ],
            menuOnlyButtons,
            effectiveButtonWidth,
          );
        }

        // Need space for overflow button
        if (remainingSpace <= 1) {
          return _buildRowWithOptionalOverflow(
            [
              ...requiredButtons,
              ...visibleHideButtons,
            ],
            menuOnlyButtons,
            effectiveButtonWidth,
          );
        }

        final visibleFlexibleButtons = optionalFlexibleButtons
            .take(remainingSpace - 1)
            .toList();
        final overflowButtons = [
          ...optionalFlexibleButtons.skip(remainingSpace - 1),
          ...menuOnlyButtons,
        ];

        return _buildRowWithOptionalOverflow(
          [
            ...requiredButtons,
            ...visibleHideButtons,
            ...visibleFlexibleButtons,
          ],
          overflowButtons,
          effectiveButtonWidth,
        );
      },
    );
  }

  Widget _buildScrollableLayout() {
    final buttonsToShow = widget.maxVisibleButtons != null
        ? widget.buttons.take(widget.maxVisibleButtons!).toList()
        : widget.buttons;

    final length = buttonsToShow.length;
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
            children: _buildButtonWidgets(buttonsToShow),
          ),
          // Otherwise, use horizontal scroll
          false => SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            controller: widget.scrollController,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _buildButtonWidgets(buttonsToShow),
            ),
          ),
        };
      },
    );
  }

  Widget _buildWrapLayout() {
    final buttonsToShow = widget.maxVisibleButtons != null
        ? widget.buttons.take(widget.maxVisibleButtons!).toList()
        : widget.buttons;

    return Wrap(
      spacing: widget.spacing,
      runSpacing: widget.runSpacing,
      alignment: widget.alignment,
      children: _buildButtonWidgets(buttonsToShow),
    );
  }

  List<Widget> _buildButtonWidgets([List<ButtonData>? buttons]) {
    final buttonsToUse = buttons ?? widget.buttons;
    final effectiveButtonWidth = widget.buttonWidth;

    return buttonsToUse
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
            if (entry.key < buttonsToUse.length - 1)
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
