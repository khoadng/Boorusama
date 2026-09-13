import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class KurumiSwitchListTile extends StatelessWidget {
  const KurumiSwitchListTile({
    required this.value,
    required this.onChanged,
    super.key,
    this.title,
    this.subtitle,
    this.secondary,
    this.activeColor,
    this.activeTrackColor,
    this.inactiveThumbColor,
    this.inactiveTrackColor,
    this.thumbColor,
    this.trackColor,
    this.trackOutlineColor,
    this.thumbIcon,
    this.materialTapTargetSize,
    this.mouseCursor,
    this.overlayColor,
    this.splashRadius,
    this.focusNode,
    this.onFocusChange,
    this.autofocus = false,
    this.tileColor,
    this.isThreeLine = false,
    this.dense,
    this.contentPadding,
    this.selected = false,
    this.controlAffinity,
    this.shape,
    this.selectedTileColor,
    this.visualDensity,
    this.enableFeedback,
    this.hoverColor,
  });

  final bool value;
  final ValueChanged<bool>? onChanged;
  final Widget? title;
  final Widget? subtitle;
  final Widget? secondary;
  final Color? activeColor;
  final Color? activeTrackColor;
  final Color? inactiveThumbColor;
  final Color? inactiveTrackColor;
  final WidgetStateProperty<Color?>? thumbColor;
  final WidgetStateProperty<Color?>? trackColor;
  final WidgetStateProperty<Color?>? trackOutlineColor;
  final WidgetStateProperty<Icon?>? thumbIcon;
  final MaterialTapTargetSize? materialTapTargetSize;
  final MouseCursor? mouseCursor;
  final WidgetStateProperty<Color?>? overlayColor;
  final double? splashRadius;
  final FocusNode? focusNode;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final Color? tileColor;
  final bool isThreeLine;
  final bool? dense;
  final EdgeInsetsGeometry? contentPadding;
  final bool selected;
  final ListTileControlAffinity? controlAffinity;
  final ShapeBorder? shape;
  final Color? selectedTileColor;
  final VisualDensity? visualDensity;
  final bool? enableFeedback;
  final Color? hoverColor;

  @override
  Widget build(BuildContext context) {
    final selectionFeedback = KurumiTheme.maybeBehaviorOf(
      context,
    )?.selectionFeedback;

    return SwitchListTile(
      value: value,
      onChanged: onChanged == null
          ? null
          : (value) {
              selectionFeedback?.call();
              onChanged!(value);
            },
      title: title,
      subtitle: subtitle,
      secondary: secondary,
      activeThumbColor: activeColor,
      activeTrackColor: activeTrackColor,
      inactiveThumbColor: inactiveThumbColor,
      inactiveTrackColor: inactiveTrackColor,
      thumbColor: thumbColor,
      trackColor: trackColor,
      trackOutlineColor: trackOutlineColor,
      thumbIcon: thumbIcon,
      materialTapTargetSize: materialTapTargetSize,
      mouseCursor: mouseCursor,
      overlayColor: overlayColor,
      splashRadius: splashRadius,
      focusNode: focusNode,
      onFocusChange: onFocusChange,
      autofocus: autofocus,
      tileColor: tileColor,
      isThreeLine: isThreeLine,
      dense: dense,
      contentPadding: contentPadding,
      selected: selected,
      controlAffinity: controlAffinity,
      shape: shape,
      selectedTileColor: selectedTileColor,
      visualDensity: visualDensity,
      enableFeedback: enableFeedback,
      hoverColor: hoverColor,
    );
  }
}
