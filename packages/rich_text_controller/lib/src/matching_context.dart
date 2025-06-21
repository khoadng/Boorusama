import 'package:flutter/widgets.dart';

import 'match_result.dart';

class MatchingContext {
  const MatchingContext({
    required this.fullText,
    required this.selection,
    required this.isBackspacing,
    this.state = const {},
    this.previousMatches = const [],
  });

  final String fullText;
  final TextSelection selection;
  final bool isBackspacing;
  final Map<String, dynamic> state;
  final List<MatchResult> previousMatches;

  String textBefore(int position) =>
      position > 0 ? fullText.substring(0, position) : '';

  String textAfter(int position) =>
      position < fullText.length ? fullText.substring(position) : '';
}
