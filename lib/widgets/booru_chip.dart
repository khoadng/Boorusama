// Flutter imports:
import 'package:flutter/material.dart' hide ThemeMode;

// Project imports:
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class BooruChip extends StatelessWidget {
  const BooruChip({
    super.key,
    this.color,
    this.onPressed,
    required this.label,
    this.trailing,
    this.contentPadding,
    this.visualDensity,
  });

  final Color? color;
  final VoidCallback? onPressed;
  final Widget label;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final VisualDensity? visualDensity;

  @override
  Widget build(BuildContext context) {
    final colors =
        color != null ? generateChipColors(color!, context.themeMode) : null;

    return trailing != null
        ? ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              visualDensity: visualDensity,
              foregroundColor: colors?.foregroundColor,
              padding: const EdgeInsets.only(left: 6, right: 2),
              backgroundColor: colors?.backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(8)),
              ),
              side: BorderSide(
                color: colors?.borderColor ?? Colors.transparent,
              ),
            ),
            onPressed: onPressed,
            icon: trailing!,
            label: label,
          )
        : ElevatedButton(
            style: ElevatedButton.styleFrom(
              visualDensity: visualDensity,
              foregroundColor: colors?.foregroundColor,
              padding:
                  contentPadding ?? const EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: colors?.backgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(16)),
              ),
              side: BorderSide(
                color: colors?.borderColor ?? Colors.transparent,
              ),
            ),
            onPressed: onPressed,
            child: label,
          );
  }
}
