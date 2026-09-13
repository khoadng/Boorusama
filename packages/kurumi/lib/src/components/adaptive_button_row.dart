import 'dart:math';

import 'package:anchor_ui/anchor_ui.dart';
import 'package:material_ui/material_ui.dart';

import '../foundation/platform.dart';
import 'anchor.dart';

const double _kMinButtonWidth = 40;
const double _kMaxButtonWidth = 150;
const double _kDefaultSpacing = 8;
const double _kWrapSpacing = 4;

enum KurumiOverflowStrategy { menu, wrap, scrollable }

enum KurumiButtonPlacement { flexible, hideOnOverflow, menuOnly }

class KurumiButtonData {
  const KurumiButtonData({
    required this.widget,
    required this.title,
    this.onTap,
    this.required = false,
    this.placement = KurumiButtonPlacement.flexible,
  });

  final Widget widget;
  final String title;
  final VoidCallback? onTap;
  final bool required;
  final KurumiButtonPlacement placement;
}

class KurumiAdaptiveButtonRow extends StatefulWidget {
  const KurumiAdaptiveButtonRow._({
    required this.buttons,
    required this.overflowStrategy,
    this.buttonWidth,
    this.spacing = _kDefaultSpacing,
    this.overflowIcon,
    this.overflowLabel,
    this.onOverflow,
    this.scrollController,
    this.runSpacing = _kDefaultSpacing,
    this.alignment,
    this.maxVisibleButtons,
    this.padding,
    this.onOpened,
    this.onClosed,
    this.onMenuTap,
    this.reduceAnimation,
    super.key,
  });

  factory KurumiAdaptiveButtonRow.menu({
    required List<KurumiButtonData> buttons,
    required String overflowLabel,
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
    bool? reduceAnimation,
    Key? key,
  }) => KurumiAdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: KurumiOverflowStrategy.menu,
    buttonWidth: buttonWidth,
    spacing: spacing,
    overflowIcon: overflowIcon,
    overflowLabel: overflowLabel,
    onOverflow: onOverflow,
    maxVisibleButtons: maxVisibleButtons,
    alignment: alignment,
    padding: padding,
    onOpened: onOpened,
    onClosed: onClosed,
    onMenuTap: onMenuTap,
    reduceAnimation: reduceAnimation,
    key: key,
  );

  factory KurumiAdaptiveButtonRow.scrollable({
    required List<KurumiButtonData> buttons,
    double? buttonWidth,
    double spacing = _kDefaultSpacing,
    ScrollController? scrollController,
    int? maxVisibleButtons,
    MainAxisAlignment? alignment,
    EdgeInsetsGeometry? padding,
    bool? reduceAnimation,
    Key? key,
  }) => KurumiAdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: KurumiOverflowStrategy.scrollable,
    buttonWidth: buttonWidth,
    spacing: spacing,
    scrollController: scrollController,
    maxVisibleButtons: maxVisibleButtons,
    alignment: alignment,
    padding: padding,
    reduceAnimation: reduceAnimation,
    key: key,
  );

  factory KurumiAdaptiveButtonRow.wrap({
    required List<KurumiButtonData> buttons,
    double? buttonWidth,
    double spacing = _kWrapSpacing,
    double runSpacing = _kWrapSpacing,
    MainAxisAlignment? alignment,
    int? maxVisibleButtons,
    EdgeInsetsGeometry? padding,
    bool? reduceAnimation,
    Key? key,
  }) => KurumiAdaptiveButtonRow._(
    buttons: buttons,
    overflowStrategy: KurumiOverflowStrategy.wrap,
    buttonWidth: buttonWidth,
    spacing: spacing,
    runSpacing: runSpacing,
    alignment: alignment,
    maxVisibleButtons: maxVisibleButtons,
    padding: padding,
    reduceAnimation: reduceAnimation,
    key: key,
  );

  final List<KurumiButtonData> buttons;
  final KurumiOverflowStrategy overflowStrategy;
  final double? buttonWidth;
  final double spacing;
  final int? maxVisibleButtons;
  final MainAxisAlignment? alignment;
  final EdgeInsetsGeometry? padding;
  final bool? reduceAnimation;
  final Widget? overflowIcon;
  final String? overflowLabel;
  final ValueChanged<int>? onOverflow;
  final VoidCallback? onOpened;
  final VoidCallback? onClosed;
  final VoidCallback? onMenuTap;
  final ScrollController? scrollController;
  final double runSpacing;

  @override
  State<KurumiAdaptiveButtonRow> createState() =>
      _KurumiAdaptiveButtonRowState();
}

class _KurumiAdaptiveButtonRowState extends State<KurumiAdaptiveButtonRow> {
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
        KurumiOverflowStrategy.menu => _buildMenuLayout(),
        KurumiOverflowStrategy.scrollable => _buildScrollableLayout(),
        KurumiOverflowStrategy.wrap => _buildWrapLayout(),
      },
    );
  }

  Widget _buildRowWithOptionalOverflow(
    List<KurumiButtonData> mainButtons,
    List<KurumiButtonData> overflowButtons,
    double buttonWidth,
  ) {
    if (overflowButtons.isEmpty) {
      return _buildRow(mainButtons, buttonWidth);
    }

    return _buildRow([
      ...mainButtons,
      KurumiButtonData(
        widget: _buildOverflowButton(overflowButtons, mainButtons.length),
        title: widget.overflowLabel!,
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
            .where((button) => button.required)
            .toList();
        final flexibleButtons = widget.buttons
            .where(
              (button) =>
                  !button.required &&
                  button.placement == KurumiButtonPlacement.flexible,
            )
            .toList();
        final hideOnOverflowButtons = widget.buttons
            .where(
              (button) =>
                  !button.required &&
                  button.placement == KurumiButtonPlacement.hideOnOverflow,
            )
            .toList();
        final menuOnlyButtons = widget.buttons
            .where(
              (button) => button.placement == KurumiButtonPlacement.menuOnly,
            )
            .toList();

        assert(
          requiredButtons.length <= maxButtons,
          'Too many required buttons (${requiredButtons.length}) for max visible buttons ($maxButtons)',
        );

        final visibleButtons = <KurumiButtonData>[];
        final overflowButtons = <KurumiButtonData>[];

        visibleButtons.addAll(requiredButtons);

        final availableAfterRequired = maxButtons - visibleButtons.length;
        final hideButtonsToShow = hideOnOverflowButtons
            .take(availableAfterRequired)
            .toList();
        visibleButtons.addAll(hideButtonsToShow);

        final remainingSpace = maxButtons - visibleButtons.length;
        final hasOverflowContent =
            menuOnlyButtons.isNotEmpty ||
            flexibleButtons.length > remainingSpace;

        if (hasOverflowContent) {
          final spaceForFlexible = (remainingSpace - 1).clamp(
            0,
            flexibleButtons.length,
          );

          visibleButtons.addAll(flexibleButtons.take(spaceForFlexible));
          overflowButtons
            ..addAll(flexibleButtons.skip(spaceForFlexible))
            ..addAll(menuOnlyButtons);
        } else {
          visibleButtons.addAll(flexibleButtons);
        }

        return _buildRowWithOptionalOverflow(
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
          true => Row(
            mainAxisAlignment:
                widget.alignment ?? MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: _buildButtonWidgets(buttonsToShow),
          ),
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

  List<Widget> _buildButtonWidgets([List<KurumiButtonData>? buttons]) {
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
        .expand((element) => element)
        .toList();
  }

  Widget _buildRow(List<KurumiButtonData> buttons, double width) {
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
          .expand((element) => element)
          .toList(),
    );
  }

  Widget _buildOverflowButton(
    List<KurumiButtonData> overflowButtons,
    int visibleCount,
  ) {
    final isDesktop = kurumiIsDesktopPlatform();

    return KurumiAnchor(
      controller: _controller,
      onShow: widget.onOpened,
      onHide: widget.onClosed,
      spacing: 12,
      reduceAnimation: widget.reduceAnimation,
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
          children: overflowButtons.asMap().entries.map(
            (entry) {
              void handleTap() {
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
              }

              return Semantics(
                button: true,
                enabled: true,
                label: entry.value.title,
                onTap: handleTap,
                excludeSemantics: true,
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: handleTap,
                    borderRadius: BorderRadius.circular(8),
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: isDesktop ? 8 : 10,
                      ),
                      child: Row(
                        children: [
                          Flexible(
                            child: Text(entry.value.title),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ).toList(),
        ),
      ),
      child: Builder(
        builder: (context) {
          void toggleMenu() {
            _controller.toggle();
            widget.onMenuTap?.call();
          }

          return Semantics(
            button: true,
            enabled: true,
            label: widget.overflowLabel,
            onTap: toggleMenu,
            excludeSemantics: true,
            child: Material(
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: toggleMenu,
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: widget.overflowIcon ?? const Icon(Icons.more_horiz),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
