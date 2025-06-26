// Flutter imports:
import 'package:flutter/material.dart';

class QueryHighlightStyle {
  const QueryHighlightStyle({
    required this.operator,
    required this.groupingColors,
    required this.defaultColor,
    this.focus,
  });

  final Color operator;
  final List<Color> groupingColors;
  final Color defaultColor;
  final FocusStyle? focus;

  Color groupingColor(int? level) {
    final effectiveLevel = level ?? 0;

    if (groupingColors.isEmpty) {
      return defaultColor;
    }

    return groupingColors[effectiveLevel % groupingColors.length];
  }
}

class FocusStyle {
  const FocusStyle({
    required this.backgroundColor,
    required this.shadowColor,
  });

  final Color backgroundColor;
  final Color shadowColor;
}
