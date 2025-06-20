// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import '../../../../widgets/compact_chip.dart';

class TagSearchConfigChip extends StatelessWidget {
  const TagSearchConfigChip({
    required this.tag,
    super.key,
    this.backgroundColor,
  });

  final String tag;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RawCompactChip(
      padding: const EdgeInsets.symmetric(
        vertical: 4,
        horizontal: 8,
      ),
      label: RichText(
        text: TextSpan(
          children: [
            if (tag.startsWith('-'))
              TextSpan(
                text: '—',
                style: TextStyle(
                  color: colorScheme.error,
                  fontWeight: FontWeight.w600,
                ),
              ),
            TextSpan(
              text: tag.startsWith('-') ? tag.substring(1) : tag,
              style: TextStyle(
                color: colorScheme.onSecondaryContainer,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
      backgroundColor: backgroundColor ?? colorScheme.secondaryContainer,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
