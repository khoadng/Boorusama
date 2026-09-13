import 'package:material_ui/material_ui.dart';

import '../theme/theme.dart';

class KurumiSlider extends StatelessWidget {
  const KurumiSlider({
    required this.value,
    required this.onChanged,
    super.key,
    this.onChangeStart,
    this.onChangeEnd,
    this.min = 0.0,
    this.max = 1.0,
    this.divisions,
    this.label,
    this.activeColor,
    this.inactiveColor,
    this.secondaryActiveColor,
    this.thumbColor,
    this.overlayColor,
    this.mouseCursor,
    this.semanticFormatterCallback,
    this.focusNode,
    this.autofocus = false,
    this.allowedInteraction,
    this.padding,
  });

  final double value;
  final ValueChanged<double>? onChanged;
  final ValueChanged<double>? onChangeStart;
  final ValueChanged<double>? onChangeEnd;
  final double min;
  final double max;
  final int? divisions;
  final String? label;
  final Color? activeColor;
  final Color? inactiveColor;
  final Color? secondaryActiveColor;
  final Color? thumbColor;
  final WidgetStateProperty<Color?>? overlayColor;
  final MouseCursor? mouseCursor;
  final SemanticFormatterCallback? semanticFormatterCallback;
  final FocusNode? focusNode;
  final bool autofocus;
  final SliderInteraction? allowedInteraction;
  final EdgeInsetsGeometry? padding;

  @override
  Widget build(BuildContext context) {
    final behavior = KurumiTheme.maybeBehaviorOf(context);

    return Slider(
      value: value,
      onChanged: onChanged == null
          ? null
          : (newValue) {
              if (newValue == min || newValue == max) {
                behavior?.sliderLimitFeedback?.call();
              }
              onChanged!(newValue);
            },
      onChangeStart: onChangeStart == null
          ? null
          : (value) {
              behavior?.sliderInteractionFeedback?.call();
              onChangeStart!(value);
            },
      onChangeEnd: onChangeEnd == null
          ? null
          : (value) {
              behavior?.sliderInteractionFeedback?.call();
              onChangeEnd!(value);
            },
      min: min,
      max: max,
      divisions: divisions,
      label: label,
      activeColor: activeColor,
      inactiveColor: inactiveColor,
      secondaryActiveColor: secondaryActiveColor,
      thumbColor: thumbColor,
      overlayColor: overlayColor,
      mouseCursor: mouseCursor,
      semanticFormatterCallback: semanticFormatterCallback,
      focusNode: focusNode,
      autofocus: autofocus,
      allowedInteraction: allowedInteraction,
      padding: padding,
    );
  }
}
