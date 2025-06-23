// Flutter imports:
import 'package:flutter/material.dart';

class StylingUtils {
  static TextSpan buildOperatorSpan(String text, Color color) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  static TextSpan buildParenthesisSpan(
    String text,
    Color color,
    bool isFocused,
  ) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: FontWeight.bold,
        backgroundColor: isFocused ? color.withValues(alpha: 0.1) : null,
        shadows: isFocused ? _buildFocusShadows(color) : null,
      ),
    );
  }

  static TextSpan buildFocusableSpan(
    String text,
    Color color,
    bool isFocused, {
    FontWeight fontWeight = FontWeight.bold,
  }) {
    return TextSpan(
      text: text,
      style: TextStyle(
        color: color,
        fontWeight: fontWeight,
        backgroundColor: isFocused ? color.withValues(alpha: 0.1) : null,
        shadows: isFocused ? _buildFocusShadows(color) : null,
      ),
    );
  }

  static List<Shadow> _buildFocusShadows(Color color) {
    return [
      Shadow(color: color, offset: const Offset(-0.5, 0)),
      Shadow(color: color, offset: const Offset(0.5, 0)),
      Shadow(color: color, offset: const Offset(0, -0.5)),
      Shadow(color: color, offset: const Offset(0, 0.5)),
    ];
  }
}
