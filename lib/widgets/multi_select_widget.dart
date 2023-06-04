// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'multi_select_controller.dart';

typedef ScrollableWidgetBuilder<T> = Widget Function(
    BuildContext context, List<T> items, IndexedWidgetBuilder itemBuilder);

typedef FooterBuilder<T> = Widget Function(
  BuildContext context,
  List<T> selectedItems,
);

typedef HeaderBuilder<T> = Widget Function(
  BuildContext context,
  List<T> selectedItems,
  VoidCallback clearSelected,
);

class MultiSelectWidget<T> extends StatefulWidget {
  const MultiSelectWidget({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.scrollableWidgetBuilder,
    this.footerBuilder,
    this.headerBuilder,
    this.multiSelectController,
    this.onMultiSelectChanged,
  });
  final List<T> items;
  final IndexedWidgetBuilder itemBuilder;
  final ScrollableWidgetBuilder<T> scrollableWidgetBuilder;
  final FooterBuilder<T>? footerBuilder;
  final HeaderBuilder<T>? headerBuilder;
  final MultiSelectController<T>? multiSelectController;
  final void Function(bool multiSelect)? onMultiSelectChanged;

  @override
  State<MultiSelectWidget<T>> createState() => _MultiSelectWidgetState<T>();
}

class _MultiSelectWidgetState<T> extends State<MultiSelectWidget<T>> {
  late MultiSelectController<T> _controller;
  var multiSelect = false;

  @override
  void initState() {
    super.initState();
    _controller = widget.multiSelectController ?? MultiSelectController();

    _controller.addListener(_onMultiSelectChanged);
  }

  @override
  void dispose() {
    if (widget.multiSelectController == null) {
      _controller.dispose();
    }
    _controller.removeListener(_onMultiSelectChanged);

    super.dispose();
  }

  void _onMultiSelectChanged() {
    setState(() {
      if (_controller.multiSelectEnabled != multiSelect) {
        widget.onMultiSelectChanged?.call(_controller.multiSelectEnabled);
      }
      multiSelect = _controller.multiSelectEnabled;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: multiSelect && widget.headerBuilder != null
                ? widget.headerBuilder!(context, _controller.selectedItems,
                    _controller.clearSelected)
                : const SizedBox.shrink()),
        body: widget.scrollableWidgetBuilder(
          context,
          widget.items,
          (context, index) {
            return multiSelect
                ? SelectableItem(
                    index: index,
                    isSelected:
                        _controller.selectedItems.contains(widget.items[index]),
                    onTap: () =>
                        _controller.toggleSelection(widget.items[index]),
                    itemBuilder: widget.itemBuilder,
                  )
                : widget.itemBuilder(context, index);
          },
        ),
        bottomSheet: multiSelect && widget.footerBuilder != null
            ? widget.footerBuilder!(context, _controller.selectedItems)
            : const SizedBox.shrink());
  }
}

class SelectableItem extends StatefulWidget {
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final IndexedWidgetBuilder itemBuilder;

  const SelectableItem({
    Key? key,
    required this.isSelected,
    required this.onTap,
    required this.itemBuilder,
    required this.index,
  }) : super(key: key);

  @override
  State<SelectableItem> createState() => _SelectableItemState();
}

class _SelectableItemState extends State<SelectableItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 80),
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.97,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(SelectableItem oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.isSelected != widget.isSelected) {
      _animationController
          .forward()
          .then((value) => _animationController.reverse());
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) => Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        ),
        child: Stack(
          alignment: Alignment.bottomRight,
          children: [
            widget.itemBuilder(context, widget.index),
            if (widget.isSelected)
              Container(
                margin: const EdgeInsets.all(8.0),
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  FontAwesomeIcons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.onBackground,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
