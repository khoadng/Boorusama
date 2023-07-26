// Flutter imports:
import 'package:flutter/material.dart';

// Project imports:
import 'package:boorusama/widgets/booru_chip.dart';

class RelatedTagButton extends StatelessWidget {
  const RelatedTagButton({
    super.key,
    required this.backgroundColor,
    required this.onPressed,
    required this.label,
  });

  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: BooruChip(
        color: backgroundColor,
        onPressed: onPressed,
        label: const Icon(Icons.add),
        trailing: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          child: label,
        ),
      ),
    );
  }
}
