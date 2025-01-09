// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

class TagChipsPlaceholder extends StatelessWidget {
  const TagChipsPlaceholder({
    super.key,
    this.height,
    this.itemCount,
    this.backgroundColor,
  });

  final double? height;
  final int? itemCount;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      height: height ?? 40,
      child: ListView.builder(
        addAutomaticKeepAlives: false,
        addRepaintBoundaries: false,
        addSemanticIndexes: false,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount ?? 20,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 8 : 4,
              right: 4,
            ),
            child: ChoiceChip(
              disabledColor: Theme.of(context).colorScheme.surfaceContainer,
              label: SizedBox(width: Random().nextInt(40).toDouble() + 40),
              selected: false,
              padding: const EdgeInsets.all(4),
              labelPadding: const EdgeInsets.all(1),
              visualDensity: VisualDensity.compact,
            ),
          );
        },
      ),
    );
  }
}
