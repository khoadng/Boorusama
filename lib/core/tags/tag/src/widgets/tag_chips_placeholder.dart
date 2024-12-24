// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../theme.dart';

class TagChipsPlaceholder extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = ref.watch(colorSchemeProvider);

    return Container(
      color: backgroundColor,
      height: height ?? 40,
      child: ListView.builder(
        shrinkWrap: true,
        scrollDirection: Axis.horizontal,
        itemCount: itemCount ?? 20,
        itemBuilder: (context, index) {
          return Padding(
            padding: EdgeInsets.only(
              left: index == 0 ? 8 : 4,
              right: 4,
            ),
            child: ChoiceChip(
              disabledColor: colorScheme.surfaceContainer,
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
