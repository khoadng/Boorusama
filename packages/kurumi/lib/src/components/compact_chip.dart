import 'package:material_ui/material_ui.dart';

class KurumiCompactChip extends StatelessWidget {
  const KurumiCompactChip({
    required this.label,
    super.key,
    this.onTap,
    this.backgroundColor,
    this.textColor,
    this.borderRadius,
    this.padding,
    this.textStyle,
  });

  final VoidCallback? onTap;
  final String label;
  final Color? backgroundColor;
  final Color? textColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry? padding;
  final TextStyle? textStyle;

  @override
  Widget build(BuildContext context) {
    return KurumiRawCompactChip(
      padding: padding,
      onTap: onTap,
      label: Text(
        label,
        softWrap: false,
        maxLines: 1,
        style:
            textStyle ??
            TextStyle(
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

class KurumiRawCompactChip extends StatelessWidget {
  const KurumiRawCompactChip({
    required this.label,
    super.key,
    this.onTap,
    this.backgroundColor,
    this.foregroundColor,
    this.padding,
    this.shape,
  });

  final VoidCallback? onTap;
  final Widget label;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final EdgeInsetsGeometry? padding;
  final ShapeBorder? shape;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: onTap != null,
      enabled: onTap != null,
      onTap: onTap,
      child: Material(
        shape: shape,
        color: backgroundColor,
        child: InkWell(
          customBorder: shape,
          overlayColor: foregroundColor != null
              ? _FilledButtonDefaultOverlay(foregroundColor!)
              : null,
          onTap: () => onTap?.call(),
          child: Container(
            padding:
                padding ??
                const EdgeInsets.symmetric(
                  vertical: 2,
                  horizontal: 6,
                ),
            child: label,
          ),
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
      return overlay.withValues(alpha: 0.12);
    }
    if (states.contains(WidgetState.hovered)) {
      return overlay.withValues(alpha: 0.08);
    }
    if (states.contains(WidgetState.focused)) {
      return overlay.withValues(alpha: 0.12);
    }
    return null;
  }
}
