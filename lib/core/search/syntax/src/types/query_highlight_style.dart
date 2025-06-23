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

  Color groupingColor(int level) =>
      groupingColors[level % groupingColors.length];
}

class FocusStyle {
  const FocusStyle({
    required this.backgroundColor,
    required this.shadowColor,
  });

  final Color backgroundColor;
  final Color shadowColor;
}
