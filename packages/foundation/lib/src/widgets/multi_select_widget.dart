// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'multi_select_controller.dart';

typedef FooterBuilder<T> = Widget Function(
  BuildContext context,
  List<T> selectedItems,
);

class MultiSelectWidget<T> extends StatefulWidget {
  const MultiSelectWidget({
    super.key,
    this.footer,
    this.header,
    this.multiSelectController,
    this.onMultiSelectChanged,
    required this.child,
  });
  final Widget? footer;
  final Widget? header;
  final MultiSelectController<T>? multiSelectController;
  final void Function(bool multiSelect)? onMultiSelectChanged;
  final Widget child;

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
        resizeToAvoidBottomInset: false,
        appBar: PreferredSize(
            preferredSize: const Size.fromHeight(kToolbarHeight),
            child: multiSelect && widget.header != null
                ? widget.header!
                : const SizedBox.shrink()),
        body: widget.child,
        bottomSheet: multiSelect && widget.footer != null
            ? Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.viewPaddingOf(context).bottom,
                ),
                child: widget.footer,
              )
            : const SizedBox.shrink());
  }
}

class SelectableItem extends StatefulWidget {
  const SelectableItem({
    super.key,
    required this.isSelected,
    required this.onTap,
    required this.itemBuilder,
    required this.index,
  });
  final int index;
  final bool isSelected;
  final VoidCallback onTap;
  final IndexedWidgetBuilder itemBuilder;

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
                  Icons.check,
                  size: 18,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
