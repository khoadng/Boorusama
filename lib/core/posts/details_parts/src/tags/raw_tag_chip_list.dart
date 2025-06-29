import 'package:flutter/material.dart';

class RawTagChipList<T> extends StatelessWidget {
  const RawTagChipList({
    required this.items,
    required this.chipBuilder,
    super.key,
    this.padding,
    this.spacing = 4,
    this.runSpacing = 4,
  });

  final List<T> items;
  final Widget Function(BuildContext, T) chipBuilder;
  final EdgeInsetsGeometry? padding;
  final double spacing;
  final double runSpacing;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: padding,
      child: Wrap(
        spacing: spacing,
        runSpacing: runSpacing,
        children: items.map((item) => chipBuilder(context, item)).toList(),
      ),
    );
  }
}
