// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/foundation/theme/theme.dart';
import 'package:boorusama/widgets/booru_chip.dart';

class RelatedTagButton extends StatelessWidget {
  const RelatedTagButton({
    super.key,
    required this.backgroundColor,
    required this.onPressed,
    required this.label,
    required this.theme,
  });

  final Color backgroundColor;
  final VoidCallback onPressed;
  final Widget label;
  final ThemeMode theme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: BooruChip(
        color: backgroundColor,
        onPressed: onPressed,
        label: const Icon(Icons.add),
        theme: theme,
        trailing: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          child: label,
        ),
      ),
    );
  }
}
