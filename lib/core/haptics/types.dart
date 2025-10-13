// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:i18n/i18n.dart';

enum HapticFeedbackLevel {
  none,
  reduced,
  balanced,
  full;

  factory HapticFeedbackLevel.parse(dynamic value) => switch (value) {
    'none' || '0' || 0 => none,
    'reduced' || '1' || 1 => reduced,
    'balanced' || '2' || 2 => balanced,
    'full' || '3' || 3 => full,
    _ => defaultValue,
  };

  static const HapticFeedbackLevel defaultValue = balanced;

  bool get isReducedOrAbove => switch (this) {
    reduced || balanced || full => true,
    _ => false,
  };
  bool get isBalanceAndAbove => switch (this) {
    balanced || full => true,
    _ => false,
  };

  bool get hasHapticFeedback => this != none;

  bool get isFull => this == full;

  String localize(BuildContext context) => switch (this) {
    none =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .none,
    reduced =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .subtle,
    balanced =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .standard,
    full =>
      context
          .t
          .settings
          .accessibility
          .haptic_feedback
          .haptic_feedback_level
          .playful,
  };

  dynamic toData() => index;
}
