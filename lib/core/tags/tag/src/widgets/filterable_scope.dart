// Flutter imports:
import 'package:flutter/material.dart';

class FilterableScope<T> extends StatefulWidget {
  const FilterableScope({
    super.key,
    required this.originalItems,
    required this.filter,
    required this.builder,
    this.query,
  });

  final String? query;
  final List<T> originalItems;
  final bool Function(T item, String query) filter;
  final Widget Function(BuildContext context, List<T> items) builder;

  @override
  State<FilterableScope<T>> createState() => _FilterableScopeState<T>();
}

class _FilterableScopeState<T> extends State<FilterableScope<T>> {
  late String query = widget.query ?? '';

  @override
  void didUpdateWidget(covariant FilterableScope<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.query != widget.query) {
      query = widget.query ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    // if query is empty, return the original items otherwise filter the items
    final items = query.isEmpty
        ? widget.originalItems
        : widget.originalItems
            .where((element) => widget.filter(element, query))
            .toList();

    return widget.builder(
      context,
      items,
    );
  }
}
