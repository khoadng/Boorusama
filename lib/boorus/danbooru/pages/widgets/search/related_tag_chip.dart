// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/flutter.dart';
import 'package:boorusama/widgets/booru_chip.dart';

class RelatedTagButton extends StatelessWidget {
  const RelatedTagButton({
    super.key,
    this.backgroundColor,
    required this.onPressed,
    required this.label,
  });

  final Color? backgroundColor;
  final VoidCallback onPressed;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: BooruChip(
        color: backgroundColor,
        onPressed: onPressed,
        label: const Icon(Symbols.add),
        trailing: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: context.screenWidth * 0.5),
          child: label,
        ),
      ),
    );
  }
}
