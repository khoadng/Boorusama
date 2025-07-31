// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Project imports:
import '../settings/providers.dart';
import '../settings/settings.dart';

class BooruSlider extends ConsumerWidget {
  const BooruSlider({
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
  Widget build(BuildContext context, WidgetRef ref) {
    final hapticLevel = ref.watch(hapticFeedbackLevelProvider);

    return Slider(
      value: value,
      onChanged: (newValue) {
        _handleChangeHapticFeedback(hapticLevel, newValue);

        if (onChanged case final callback?) {
          callback(newValue);
        }
      },
      onChangeStart: (value) {
        if (hapticLevel.isBalanceAndAbove) {
          HapticFeedback.lightImpact();
        }
        if (onChangeStart case final callback?) {
          callback(value);
        }
      },
      onChangeEnd: (value) {
        if (hapticLevel.isBalanceAndAbove) {
          HapticFeedback.lightImpact();
        }
        if (onChangeEnd case final callback?) {
          callback(value);
        }
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

  void _handleChangeHapticFeedback(HapticFeedbackLevel level, double newValue) {
    if (!level.isReducedOrAbove) return;

    // Min/max feedback for reduced+ levels
    if (newValue == min || newValue == max) {
      HapticFeedback.mediumImpact();
    }
  }
}
