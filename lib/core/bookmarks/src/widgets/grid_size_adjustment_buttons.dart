// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

class GridSizeAdjustmentButtons extends StatelessWidget {
  const GridSizeAdjustmentButtons({
    required this.count,
    required this.maxCount,
    required this.minCount,
    required this.onAdded,
    required this.onDecreased,
    super.key,
  });

  final int count;
  final int maxCount;
  final int minCount;
  final void Function(int count) onAdded;
  final void Function(int count) onDecreased;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: OverflowBar(
        children: [
          IconButton(
            onPressed: count > minCount ? () => onDecreased(count) : null,
            icon: const Icon(Symbols.remove),
          ),
          IconButton(
            onPressed: count < maxCount ? () => onAdded(count) : null,
            icon: const Icon(Symbols.add),
          ),
        ],
      ),
    );
  }
}
