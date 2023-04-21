// Flutter imports:
import 'package:flutter/material.dart';

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

    _controller.addListener(() {
      multiSelect = _controller.multiSelectEnabled;
    });
  }

  @override
  void dispose() {
    if (widget.multiSelectController == null) {
      _controller.dispose();
    }
    super.dispose();
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
            var item = widget.items[index];
            return multiSelect
                ? GestureDetector(
                    onTap: () {
                      _controller.toggleSelection(item);
                      //TODO: quick fix
                      setState(() {});
                    },
                    child: Stack(
                      alignment: Alignment.topRight,
                      children: [
                        widget.itemBuilder(context, index),
                        if (multiSelect &&
                            _controller.selectedItems.contains(item))
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child:
                                Icon(Icons.check_circle, color: Colors.green),
                          ),
                      ],
                    ),
                  )
                : widget.itemBuilder(context, index);
          },
        ),
        bottomSheet: multiSelect && widget.footerBuilder != null
            ? widget.footerBuilder!(context, _controller.selectedItems)
            : const SizedBox.shrink());
  }
}
