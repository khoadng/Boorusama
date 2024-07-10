// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import 'package:boorusama/boorus/providers.dart';
import 'package:boorusama/dart.dart';
import 'package:boorusama/foundation/theme/theme.dart';

class BooruChip extends ConsumerWidget {
  const BooruChip({
    super.key,
    this.color,
    this.onPressed,
    required this.label,
    this.trailing,
    this.contentPadding,
    this.visualDensity,
    this.borderRadius,
    this.showBackground = true,
    this.showBorder = true,
    this.disabled = false,
    this.chipColors,
  });

  final Color? color;
  final VoidCallback? onPressed;
  final Widget label;
  final Widget? trailing;
  final EdgeInsetsGeometry? contentPadding;
  final VisualDensity? visualDensity;
  final BorderRadiusGeometry? borderRadius;
  final bool showBackground;
  final bool showBorder;
  final bool disabled;
  final ChipColors? chipColors;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = chipColors ??
        (color != null
            ? context.generateChipColors(
                color!,
                ref.watch(settingsProvider),
              )
            : null);

    return trailing != null
        ? FilledButton.icon(
            style: FilledButton.styleFrom(
              visualDensity: visualDensity,
              foregroundColor: colors?.foregroundColor,
              padding: const EdgeInsets.only(left: 6, right: 2),
              backgroundColor: showBackground
                  ? !disabled
                      ? colors?.backgroundColor
                      : Colors.transparent
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    borderRadius ?? const BorderRadius.all(Radius.circular(8)),
              ),
              side: showBorder
                  ? BorderSide(
                      color: !disabled
                          ? colors?.borderColor ?? Colors.transparent
                          : colors?.borderColor.withOpacity(0.5) ??
                              Colors.transparent,
                    )
                  : null,
            ),
            onPressed: onPressed,
            icon: trailing!,
            label: label,
          )
        : FilledButton(
            style: FilledButton.styleFrom(
              visualDensity: visualDensity,
              foregroundColor: colors?.foregroundColor,
              padding:
                  contentPadding ?? const EdgeInsets.symmetric(horizontal: 8),
              backgroundColor: showBackground
                  ? !disabled
                      ? colors?.backgroundColor
                      : Colors.transparent
                  : Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius:
                    borderRadius ?? const BorderRadius.all(Radius.circular(16)),
              ),
              side: showBorder
                  ? BorderSide(
                      color: !disabled
                          ? colors?.borderColor ?? Colors.transparent
                          : colors?.borderColor.withOpacity(0.5) ??
                              Colors.transparent,
                    )
                  : null,
            ),
            onPressed: onPressed,
            child: label,
          );
  }
}
