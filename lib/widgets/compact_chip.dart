// Flutter imports:
import 'package:flutter/material.dart';

// Package imports:
import 'package:auto_size_text/auto_size_text.dart';

class CompactChip extends StatelessWidget {
  const CompactChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
  });

  final void Function()? onTap;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    return RawCompactChip(
      padding: padding,
      onTap: onTap,
      label: AutoSizeText(
        label,
        softWrap: false,
        maxLines: 1,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      backgroundColor: backgroundColor,
      foregroundColor: textColor,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadius ?? BorderRadius.circular(4),
      ),
    );
  }
}

class RawCompactChip extends StatelessWidget {
  const RawCompactChip({
    super.key,
    required this.label,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.shape,
  });

  final void Function()? onTap;
  final Widget label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Material(
      shape: shape,
      color: backgroundColor,
      child: InkWell(
        customBorder: shape,
        overlayColor: foregroundColor != null
            ? _FilledButtonDefaultOverlay(foregroundColor!)
            : null,
        onTap: () => onTap?.call(),
        child: Container(
          padding: padding ??
              const EdgeInsets.symmetric(
                vertical: 2,
                horizontal: 6,
              ),
          child: label,
        ),
      ),
    );
  }
}

class _FilledButtonDefaultOverlay extends WidgetStateProperty<Color?> {
  _FilledButtonDefaultOverlay(this.overlay);

  final Color overlay;

  @override
  Color? resolve(Set<WidgetState> states) {
    if (states.contains(WidgetState.pressed)) {
      return overlay.withOpacity(0.12);
    }
    if (states.contains(WidgetState.hovered)) {
      return overlay.withOpacity(0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return overlay.withOpacity(0.12);
    }
    return null;
  }
}
