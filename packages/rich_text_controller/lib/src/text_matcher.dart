import 'package:flutter/widgets.dart';

import 'match_result.dart';
import 'matching_context.dart';

abstract class TextMatcher {
  const TextMatcher({this.priority = 0});

  final int priority;

  List<MatchResult> findMatches(MatchingContext context);
  InlineSpan buildSpan(MatchResult match, MatchingContext context);
}
