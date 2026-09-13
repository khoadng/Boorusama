import 'package:material_ui/material_ui.dart';

/// The app's shared selectable/tag chip surface.
///
/// This keeps the existing compact Material chip behavior in one Kurumi
/// primitive while allowing feature code to supply its own label, selection
/// state, and domain colors.
class KurumiSelectableChip extends StatelessWidget {
  const KurumiSelectableChip({
    required this.label,
    super.key,
    this.selected = false,
    this.onSelected,
    this.onPressed,
    this.onDeleted,
    this.deleteIcon,
    this.deleteButtonTooltipMessage,
    this.avatar,
    this.backgroundColor,
    this.selectedColor,
    this.disabledColor,
    this.checkmarkColor,
    this.side,
    this.shape,
    this.padding,
    this.labelPadding,
    this.visualDensity,
    this.labelStyle,
    this.showCheckmark = true,
    this.tapEnabled,
    this.isEnabled = true,
    this.defaultProperties,
    this.deleteIconColor,
    this.pressElevation,
    this.tooltip,
    this.clipBehavior = Clip.none,
    this.focusNode,
    this.autofocus = false,
    this.color,
    this.elevation,
    this.shadowColor,
    this.surfaceTintColor,
    this.iconTheme,
    this.selectedShadowColor,
    this.avatarBorder = const CircleBorder(),
    this.avatarBoxConstraints,
    this.deleteIconBoxConstraints,
    this.chipAnimationStyle,
    this.mouseCursor,
    this.materialTapTargetSize,
  });

  final Widget label;
  final bool selected;
  final ValueChanged<bool>? onSelected;
  final VoidCallback? onPressed;
  final VoidCallback? onDeleted;
  final Widget? deleteIcon;
  final String? deleteButtonTooltipMessage;
  final Widget? avatar;
  final Color? backgroundColor;
  final Color? selectedColor;
  final Color? disabledColor;
  final Color? checkmarkColor;
  final BorderSide? side;
  final OutlinedBorder? shape;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? labelPadding;
  final VisualDensity? visualDensity;
  final TextStyle? labelStyle;
  final bool showCheckmark;
  final bool? tapEnabled;
  final bool isEnabled;
  final ChipThemeData? defaultProperties;
  final Color? deleteIconColor;
  final double? pressElevation;
  final String? tooltip;
  final Clip clipBehavior;
  final FocusNode? focusNode;
  final bool autofocus;
  final WidgetStateProperty<Color?>? color;
  final double? elevation;
  final Color? shadowColor;
  final Color? surfaceTintColor;
  final IconThemeData? iconTheme;
  final Color? selectedShadowColor;
  final ShapeBorder avatarBorder;
  final BoxConstraints? avatarBoxConstraints;
  final BoxConstraints? deleteIconBoxConstraints;
  final ChipAnimationStyle? chipAnimationStyle;
  final MouseCursor? mouseCursor;
  final MaterialTapTargetSize? materialTapTargetSize;

  @override
  Widget build(BuildContext context) {
    final chip = RawChip(
      defaultProperties: defaultProperties,
      label: label,
      selected: selected,
      onSelected: onSelected,
      onPressed: onPressed,
      onDeleted: onDeleted,
      deleteIcon: deleteIcon,
      deleteIconColor: deleteIconColor,
      deleteButtonTooltipMessage: deleteButtonTooltipMessage,
      avatar: avatar,
      backgroundColor: backgroundColor,
      selectedColor: selectedColor,
      disabledColor: disabledColor,
      checkmarkColor: checkmarkColor,
      side: side,
      shape: shape,
      padding: padding,
      labelPadding: labelPadding,
      visualDensity: visualDensity,
      labelStyle: labelStyle,
      showCheckmark: showCheckmark,
      tapEnabled: tapEnabled ?? (onSelected != null || onPressed != null),
      isEnabled: isEnabled,
      pressElevation: pressElevation,
      tooltip: tooltip,
      clipBehavior: clipBehavior,
      focusNode: focusNode,
      autofocus: autofocus,
      color: color,
      materialTapTargetSize: materialTapTargetSize,
      elevation: elevation,
      shadowColor: shadowColor,
      surfaceTintColor: surfaceTintColor,
      iconTheme: iconTheme,
      selectedShadowColor: selectedShadowColor,
      avatarBorder: avatarBorder,
      avatarBoxConstraints: avatarBoxConstraints,
      deleteIconBoxConstraints: deleteIconBoxConstraints,
      chipAnimationStyle: chipAnimationStyle,
      mouseCursor: mouseCursor,
    );

    return Semantics(
      selected: onSelected != null || selected ? selected : null,
      child: chip,
    );
  }
}
