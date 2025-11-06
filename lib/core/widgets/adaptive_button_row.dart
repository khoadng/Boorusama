// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import '../../foundation/platform.dart';

const double _kMinButtonWidth = 40;
const double _kMaxButtonWidth = 150;
const double _kDefaultSpacing = 8;
const double _kWrapSpacing = 4;

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
    this.onOverflow,
    this.scrollController,
    this.runSpacing = _kDefaultSpacing,
    this.alignment,
    this.maxVisibleButtons,
    this.padding,
    this.onOpened,
    this.onClosed,
    this.onMenuTap,
    super.key,
  });

  factory AdaptiveButtonRow.menu({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    Widget? overflowIcon,
    ValueChanged<int>? onOverflow,
    int? maxVisibleButtons,
    MainAxisAlignment? alignment,
    EdgeInsetsGeometry? padding,
    VoidCallback? onOpened,
    VoidCallback? onClosed,
    VoidCallback? onMenuTap,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.menu,
    buttonWidth: buttonWidth,
    spacing: spacing,
    overflowIcon: overflowIcon,
    onOverflow: onOverflow,
    maxVisibleButtons: maxVisibleButtons,
    alignment: alignment,
    padding: padding,
    onOpened: onOpened,
    onClosed: onClosed,
    onMenuTap: onMenuTap,
    key: key,
  );

  factory AdaptiveButtonRow.scrollable({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    ScrollController? scrollController,
    int? maxVisibleButtons,
    MainAxisAlignment? alignment,
    EdgeInsetsGeometry? padding,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.scrollable,
    buttonWidth: buttonWidth,
    spacing: spacing,
    scrollController: scrollController,
    maxVisibleButtons: maxVisibleButtons,
    alignment: alignment,
    padding: padding,
    key: key,
  );

  factory AdaptiveButtonRow.wrap({
    required List<ButtonData> buttons,
    double? buttonWidth,
    double spacing = _kWrapSpacing,
    double runSpacing = _kWrapSpacing,
    MainAxisAlignment? alignment,
    int? maxVisibleButtons,
    EdgeInsetsGeometry? padding,
    Key? key,
  }) => AdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: OverflowStrategy.wrap,
    buttonWidth: buttonWidth,
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    maxVisibleButtons: maxVisibleButtons,
    padding: padding,
    key: key,
  );

  final List<ButtonData> buttons;
  final OverflowStrategy overflowStrategy;
  final double? buttonWidth;
  final double spacing;
  final int? maxVisibleButtons;
  final MainAxisAlignment? alignment;
  final EdgeInsetsGeometry? padding;

  // Menu-specific
  final Widget? overflowIcon;
  final ValueChanged<int>? onOverflow;

  // Menu callbacks
  final VoidCallback? onOpened;
  final VoidCallback? onClosed;
  final VoidCallback? onMenuTap;

  // Scroll-specific
  final ScrollController? scrollController;

  // Wrap-specific
  final double runSpacing;

  @override
  State<AdaptiveButtonRow> createState() => _AdaptiveButtonRowState();
}

class _AdaptiveButtonRowState extends State<AdaptiveButtonRow> {
  final _controller = AnchorController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.buttons.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 12),
      child: switch (widget.overflowStrategy) {
        OverflowStrategy.menu => _buildMenuLayout(),
        OverflowStrategy.scrollable => _buildScrollableLayout(),
        OverflowStrategy.wrap => _buildWrapLayout(),
      },
    );
  }

  Widget _buildRowWithOptionalOverflow(
    BuildContext context,
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
        title: context.t.generic.action.more,
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
        final flexibleButtons = widget.buttons
            .where(
              (b) => !b.required && b.placement == ButtonPlacement.flexible,
            )
            .toList();
        final hideOnOverflowButtons = widget.buttons
            .where(
              (b) =>
                  !b.required && b.placement == ButtonPlacement.hideOnOverflow,
            )
            .toList();
        final menuOnlyButtons = widget.buttons
            .where((b) => b.placement == ButtonPlacement.menuOnly)
            .toList();

        // Ensure required buttons fit
        assert(
          requiredButtons.length <= maxButtons,
          'Too many required buttons (${requiredButtons.length}) for max visible buttons ($maxButtons)',
        );

        // Build visible and overflow button lists
        final visibleButtons = <ButtonData>[];
        final overflowButtons = <ButtonData>[];

        // Always add required buttons
        visibleButtons.addAll(requiredButtons);

        // Add hideOnOverflow buttons if they fit
        final availableAfterRequired = maxButtons - visibleButtons.length;
        final hideButtonsToShow = hideOnOverflowButtons
            .take(availableAfterRequired)
            .toList();
        visibleButtons.addAll(hideButtonsToShow);

        // Calculate remaining space
        final remainingSpace = maxButtons - visibleButtons.length;

        // Determine if we need overflow button
        final hasOverflowContent =
            menuOnlyButtons.isNotEmpty ||
            flexibleButtons.length > remainingSpace;

        if (hasOverflowContent) {
          // Reserve space for overflow button
          final spaceForFlexible = (remainingSpace - 1).clamp(
            0,
            flexibleButtons.length,
          );

          // Add flexible buttons that fit
          visibleButtons.addAll(flexibleButtons.take(spaceForFlexible));

          // Remaining flexible buttons go to overflow
          overflowButtons
            ..addAll(flexibleButtons.skip(spaceForFlexible))
            ..addAll(menuOnlyButtons);
        } else {
          // No overflow needed, add all remaining buttons
          visibleButtons.addAll(flexibleButtons);
        }

        return _buildRowWithOptionalOverflow(
          context,
          visibleButtons,
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
          // If content fits, use aligned row
          true => Row(
            mainAxisAlignment:
                widget.alignment ?? MainAxisAlignment.spaceEvenly,
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
      alignment: _mainAxisToWrapAlignment(
        widget.alignment ?? MainAxisAlignment.spaceEvenly,
      ),
      children: _buildButtonWidgets(buttonsToShow),
    );
  }

  WrapAlignment _mainAxisToWrapAlignment(MainAxisAlignment alignment) {
    return switch (alignment) {
      MainAxisAlignment.start => WrapAlignment.start,
      MainAxisAlignment.end => WrapAlignment.end,
      MainAxisAlignment.center => WrapAlignment.center,
      MainAxisAlignment.spaceBetween => WrapAlignment.spaceBetween,
      MainAxisAlignment.spaceAround => WrapAlignment.spaceAround,
      MainAxisAlignment.spaceEvenly => WrapAlignment.spaceEvenly,
    };
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
      mainAxisAlignment: widget.alignment ?? MainAxisAlignment.spaceEvenly,
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
    final colorScheme = Theme.of(context).colorScheme;

    final isDesktop = isDesktopPlatform();

    return AnchorPopover(
      controller: _controller,
      arrowShape: const NoArrow(),
      placement: Placement.bottom,
      triggerMode: const AnchorTriggerMode.manual(),
      border: BorderSide(
        color: colorScheme.outlineVariant,
        width: 0.5,
      ),
      backdropBuilder: (context) => GestureDetector(
        onTap: () {
          _controller.hide();
        },
        child: Container(
          color: isDesktop
              ? Colors.transparent
              : Colors.black.withValues(alpha: 0.75),
        ),
      ),
      boxShadow: [
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: 0.2),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
      backgroundColor: isDesktop ? null : colorScheme.surface,
      viewPadding: const EdgeInsets.all(4),
      onShow: widget.onOpened,
      onHide: widget.onClosed,
      spacing: 12,
      overlayBuilder: (context) => Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 8,
        ),
        constraints: BoxConstraints(
          maxWidth: min(MediaQuery.widthOf(context), 200),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: overflowButtons
              .asMap()
              .entries
              .map(
                (entry) => Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: () {
                      final controller = AnchorData.maybeOf(
                        context,
                      )?.controller;
                      controller?.hide();
                      widget.onMenuTap?.call();
                      final globalIndex = entry.key + visibleCount;
                      if (entry.value.onTap != null) {
                        entry.value.onTap!();
                      } else {
                        widget.onOverflow?.call(globalIndex);
                      }
                    },
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: isDesktop ? 8 : 10,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(
                              entry.value.title,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              )
              .toList(),
        ),
      ),
      child: Material(
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: () {
            _controller.toggle();
            widget.onMenuTap?.call();
          },
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: widget.overflowIcon ?? const Icon(Icons.more_horiz),
          ),
        ),
      ),
    );
  }
}
