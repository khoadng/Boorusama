// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:anchor_ui/anchor_ui.dart';
import 'package:collection/collection.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import '../../foundation/platform.dart';
import '../settings/providers.dart';
import 'booru_anchor.dart';

class OptionDropDownButton<T> extends ConsumerStatefulWidget {
  const OptionDropDownButton({
    required this.value,
    required this.onChanged,
    required this.items,
    super.key,
    this.alignment = AlignmentDirectional.centerEnd,
    this.backgroundColor,
    this.padding,
  });

  final T value;
  final void Function(T? value) onChanged;
  final List<DropdownMenuItem<T>> items;
  final AlignmentDirectional alignment;
  final Color? backgroundColor;
  final EdgeInsetsGeometry? padding;

  @override
  ConsumerState<OptionDropDownButton<T>> createState() =>
      _OptionDropDownButtonState<T>();
}

class _OptionDropDownButtonState<T>
    extends ConsumerState<OptionDropDownButton<T>> {
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
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);
    final backgroundColor =
        widget.backgroundColor ?? colorScheme.surfaceContainerHighest;
    final isDesktop = isDesktopPlatform();

    return BooruAnchor(
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
                children: widget.items
                    .asMap()
                    .entries
                    .map(
                      (entry) => _OptionDropDownItem<T>(
                        key: entry.key == 0 ? _itemKey : null,
                        value: entry.value.value as T,
                        isSelected: entry.value.value == widget.value,
                        onTap: () {
                          _controller.hide();
                          widget.onChanged(entry.value.value);
                        },
                        child: entry.value.child,
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        );
      },
      child: Card(
        color: backgroundColor,
        child: InkWell(
          onTap: () {
            if (hapticLevel.isFull) {
              HapticFeedback.selectionClick();
            }
            _controller.toggle();
            if (_controller.isShowing) {
              _scrollToSelectedItem();
            }
          },
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
                if (widget.items.firstWhereOrNull(
                      (item) => item.value == widget.value,
                    )
                    case final item?)
                  Flexible(
                    child: item.child,
                  )
                else
                  const SizedBox(
                    width: 50,
                    child: Text(
                      '',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(left: 4),
                  child: Icon(
                    Symbols.keyboard_arrow_down,
                    size: 20,
                    color: Theme.of(context).iconTheme.color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OptionDropDownItem<T> extends StatelessWidget {
  const _OptionDropDownItem({
    super.key,
    required this.value,
    required this.isSelected,
    required this.onTap,
    required this.child,
  });

  final T value;
  final bool isSelected;
  final VoidCallback onTap;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDesktop = isDesktopPlatform();

    return Material(
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
          decoration: isSelected
              ? BoxDecoration(
                  color: colorScheme.primaryContainer.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(8),
                )
              : null,
          child: Row(
            children: [
              Flexible(
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
