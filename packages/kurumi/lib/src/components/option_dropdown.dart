import 'dart:math';

import 'package:anchor_ui/anchor_ui.dart';
import 'package:collection/collection.dart';
import 'package:material_ui/material_ui.dart';
import 'package:material_symbols_icons/symbols.dart';

import '../foundation/platform.dart';
import '../theme/theme.dart';
import 'anchor.dart';

class KurumiOptionDropDownButton<T> extends StatefulWidget {
  const KurumiOptionDropDownButton({
    required this.value,
    required this.onChanged,
    required this.items,
    super.key,
    this.alignment = AlignmentDirectional.centerEnd,
    this.backgroundColor,
    this.padding,
    this.selectedItemBuilder,
    this.showArrow = true,
    this.isItemSelected,
    this.showSelectedCheckmark = false,
    this.borderSide,
    this.elevation,
    this.margin,
    this.onPressed,
    this.arrowSize = 20,
    this.arrowSpacing = 4,
    this.selectedItemFlexible = true,
  });

  final T value;
  final ValueChanged<T?> onChanged;
  final List<DropdownMenuItem<T>> items;
  final AlignmentDirectional alignment;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;
  final Widget Function(T value)? selectedItemBuilder;
  final bool showArrow;
  final bool Function(T value)? isItemSelected;
  final bool showSelectedCheckmark;
  final BorderSide? borderSide;
  final double? elevation;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onPressed;
  final double arrowSize;
  final double arrowSpacing;
  final bool selectedItemFlexible;

  @override
  State<KurumiOptionDropDownButton<T>> createState() =>
      _KurumiOptionDropDownButtonState<T>();
}

class _KurumiOptionDropDownButtonState<T>
    extends State<KurumiOptionDropDownButton<T>> {
  final _controller = AnchorController();
  final _scrollController = ScrollController();
  final _itemKey = GlobalKey();

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToSelectedItem() {
    final selectedIndex = widget.items.indexWhere(
      (item) => item.value == widget.value,
    );

    if (selectedIndex == -1) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      final itemContext = _itemKey.currentContext;
      if (itemContext == null) return;

      final itemHeight = itemContext.size?.height ?? 0;
      if (itemHeight == 0) return;

      final targetOffset = selectedIndex * itemHeight;

      _scrollController.jumpTo(
        targetOffset.clamp(
          0.0,
          _scrollController.position.maxScrollExtent,
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final menuFeedback = KurumiTheme.maybeBehaviorOf(context)?.menuFeedback;
    final backgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final isDesktop = kurumiIsDesktopPlatform();
    final selectedMenuItem = widget.items.firstWhereOrNull(
      (item) => item.value == widget.value,
    );
    final selectedItem = selectedMenuItem == null
        ? const SizedBox(
            width: 50,
            child: Text('', overflow: TextOverflow.ellipsis),
          )
        : widget.selectedItemBuilder?.call(widget.value) ??
              selectedMenuItem.child;

    void handleTap() {
      menuFeedback?.call();
      if (widget.onPressed case final onPressed?) {
        onPressed();
        return;
      }
      _controller.toggle();
      if (_controller.isShowing) {
        _scrollToSelectedItem();
      }
    }

    return KurumiAnchor(
      controller: _controller,
      viewPadding: isDesktop
          ? const EdgeInsets.all(4)
          : const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 32,
            ),
      placement: Placement.bottomEnd,
      overlayBuilder: (context) {
        return Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 4,
            vertical: 4,
          ),
          constraints: BoxConstraints(
            maxWidth: min(MediaQuery.widthOf(context), 200),
            maxHeight: min(MediaQuery.heightOf(context) / 3, 400),
          ),
          child: Scrollbar(
            controller: _scrollController,
            thickness: 4,
            radius: const Radius.circular(12),
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: widget.items.asMap().entries.map((entry) {
                  final item = entry.value;
                  if (!item.enabled) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
                      child: item.child,
                    );
                  }

                  final value = item.value as T;
                  return _OptionDropDownItem<T>(
                    key: entry.key == 0 ? _itemKey : null,
                    value: value,
                    isSelected:
                        widget.isItemSelected?.call(value) ??
                        item.value == widget.value,
                    showSelectedCheckmark: widget.showSelectedCheckmark,
                    onTap: () {
                      _controller.hide();
                      widget.onChanged(item.value);
                    },
                    child: item.child,
                  );
                }).toList(),
              ),
            ),
          ),
        );
      },
      child: Semantics(
        button: true,
        enabled: true,
        onTap: handleTap,
        child: Card(
          color: backgroundColor,
          elevation: widget.elevation,
          margin: widget.margin,
          shape: widget.borderSide == null
              ? null
              : RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                  side: widget.borderSide!,
                ),
          child: InkWell(
            onTap: handleTap,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding:
                  widget.padding ??
                  const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 8,
                  ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.selectedItemFlexible)
                    Flexible(child: selectedItem)
                  else
                    selectedItem,
                  if (widget.showArrow)
                    Padding(
                      padding: EdgeInsets.only(left: widget.arrowSpacing),
                      child: Icon(
                        Symbols.keyboard_arrow_down,
                        size: widget.arrowSize,
                        color: Theme.of(context).iconTheme.color,
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class KurumiOptionDropDownMenuHeader extends StatelessWidget {
  const KurumiOptionDropDownMenuHeader({required this.label, super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label.toUpperCase(),
      style: Theme.of(context).textTheme.labelSmall?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.5,
      ),
    );
  }
}

class _OptionDropDownItem<T> extends StatelessWidget {
  const _OptionDropDownItem({
    required this.value,
    required this.isSelected,
    required this.showSelectedCheckmark,
    required this.onTap,
    required this.child,
    super.key,
  });

  final T value;
  final bool isSelected;
  final bool showSelectedCheckmark;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = kurumiIsDesktopPlatform();

    return Semantics(
      button: true,
      selected: isSelected,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            margin: const EdgeInsets.symmetric(
              vertical: 2,
            ),
            padding: EdgeInsets.symmetric(
              horizontal: 12,
              vertical: isDesktop ? 4 : 12,
            ),
            decoration: isSelected && !showSelectedCheckmark
                ? BoxDecoration(
                    color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(8),
                  )
                : null,
            child: Row(
              children: [
                Expanded(
                  child: child,
                ),
                if (showSelectedCheckmark) ...[
                  const SizedBox(width: 12),
                  SizedBox.square(
                    dimension: 20,
                    child: isSelected
                        ? Icon(
                            Symbols.check,
                            size: 20,
                            color: colorScheme.primary,
                          )
                        : null,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
