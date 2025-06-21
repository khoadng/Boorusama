import 'package:flutter/widgets.dart';

import 'match_result.dart';
import 'matching_context.dart';
import 'text_matcher_options.dart';

abstract class TextMatcher {
  const TextMatcher({
    this.priority = 0,
    this.options = const TextMatcherOptions(),
  });

  final int priority;
  final TextMatcherOptions options;

  List<MatchResult> findMatches(MatchingContext context);
  InlineSpan buildSpan(MatchResult match, MatchingContext context);
}
