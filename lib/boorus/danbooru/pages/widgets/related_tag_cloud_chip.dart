// Dart imports:
import 'dart:math';

// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/booru_builder.dart';
import 'package:boorusama/boorus/danbooru/feats/tags/tags.dart';
import 'package:boorusama/string.dart';
import 'package:boorusama/widgets/booru_chip.dart';

class RelatedTagCloudChip extends ConsumerWidget {
  const RelatedTagCloudChip({
    required this.index,
    required this.tag,
    this.isDummy = false,
    required this.onPressed,
    super.key,
  });

  final int index;
  final RelatedTagItem tag;
  final bool isDummy;
  final VoidCallback? onPressed;

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
          tag.tag.replaceUnderscoreWithSpace(),
          style: TextStyle(
            fontSize: max((60 - (index * 2)).toDouble(), 24),
            color: isDummy ? Colors.transparent : null,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        color: ref.getTagColor(context, tag.category.name),
        onPressed: onPressed,
      ),
    );
  }
}
