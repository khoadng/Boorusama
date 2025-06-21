import 'package:flutter/widgets.dart';

class TextMatcher {
  const TextMatcher({
    required this.pattern,
    required this.spanBuilder,
  });

  TextMatcher.style({
    required this.pattern,
    required TextStyle style,
  }) : spanBuilder = ((text) => TextSpan(
         text: text,
         style: style,
       ));

  final RegExp pattern;
  final InlineSpan Function(String text) spanBuilder;
}
