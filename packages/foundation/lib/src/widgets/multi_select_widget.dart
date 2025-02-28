// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

// Project imports:
import 'multi_select_controller.dart';

typedef FooterBuilder<T> = Widget Function(
  BuildContext context,
  List<T> selectedItems,
);

const _kAnimDuration = Duration(milliseconds: 100);

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
    final footerHeight = widget.footer != null ? 52.0 : 0.0;

    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: multiSelect && widget.header != null
            ? widget.header!
            : const SizedBox.shrink(),
      ),
      body: Stack(
        children: [
          _AnimatedBody(
            multiSelect: multiSelect,
            body: widget.child,
            footerHeight: footerHeight,
          ),
          if (widget.footer != null)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _AnimatedFooter(
                multiSelect: multiSelect,
                footer: widget.footer!,
              ),
            ),
        ],
      ),
    );
  }
}

class _AnimatedBody extends StatelessWidget {
  const _AnimatedBody({
    required this.multiSelect,
    required this.body,
    required this.footerHeight,
  });

  final bool multiSelect;
  final Widget body;
  final double? footerHeight;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.viewPaddingOf(context).bottom;
    final bottom = multiSelect && footerHeight != null
        ? bottomPadding + footerHeight!
        : 0.0;

    return AnimatedPadding(
      duration: _kAnimDuration,
      curve: Curves.easeInOut,
      padding: EdgeInsets.only(
        bottom: bottom,
      ),
      child: body,
    );
  }
}

class _AnimatedFooter extends StatelessWidget {
  const _AnimatedFooter({
    required this.multiSelect,
    required this.footer,
  });

  final bool multiSelect;
  final Widget footer;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: AnimatedSlide(
        duration: _kAnimDuration,
        curve: Curves.easeInOut,
        offset: multiSelect ? Offset.zero : const Offset(0, 1),
        child: AnimatedOpacity(
          duration: _kAnimDuration,
          opacity: multiSelect ? 1.0 : 0.0,
          child: multiSelect ? footer : const SizedBox.shrink(),
        ),
      ),
    );
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
            if (widget.isSelected) _Icon(),
          ],
        ),
      ),
    );
  }
}

class _Icon extends StatelessWidget {
  const _Icon();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        shape: BoxShape.circle,
      ),
      child: Icon(
        FontAwesomeIcons.check,
        size: 18,
        color: colorScheme.onPrimary,
      ),
    );
  }
}
