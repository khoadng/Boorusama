// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme.dart';

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
    final colors = generateChipColors(backgroundColor, theme);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          foregroundColor: colors.foregroundColor,
          padding: const EdgeInsets.only(left: 6, right: 2),
          backgroundColor: colors.backgroundColor,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(8)),
          ),
          side: BorderSide(
            color: colors.borderColor,
          ),
        ),
        onPressed: onPressed,
        icon: ConstrainedBox(
          constraints:
              BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
          child: label,
        ),
        label: const Icon(Icons.add),
      ),
    );
  }
}
