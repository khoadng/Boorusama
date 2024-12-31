// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../../../widgets/booru_chip.dart';

class RelatedTagCloudChip extends ConsumerWidget {
  const RelatedTagCloudChip({
    required this.index,
    required this.tag,
    required this.onPressed,
    required this.color,
    this.isDummy = false,
    super.key,
  });

  final int index;
  final bool isDummy;
  final VoidCallback? onPressed;
  final Color? color;
  final String tag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: switch (index) {
        < 5 => const EdgeInsets.all(4),
        > 5 && < 10 => const EdgeInsets.all(2),
        _ => EdgeInsets.zero,
      },
      child: BooruChip(
        label: Text(
          tag.replaceAll('_', ' '),
          style: TextStyle(
            fontSize: max((60 - (index * 2)).toDouble(), 24),
            color: isDummy ? Colors.transparent : null,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        color: color,
        onPressed: onPressed,
      ),
    );
  }
}
