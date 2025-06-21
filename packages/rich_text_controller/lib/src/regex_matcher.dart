import 'package:flutter/widgets.dart';

import 'match_candidate.dart';
import 'match_result.dart';
import 'matching_context.dart';
import 'text_matcher.dart';

class RegexMatcher extends TextMatcher {
  const RegexMatcher({
    required this.pattern,
    required this.spanBuilder,
    this.validator,
    super.priority,
  });

  final RegExp pattern;
  final InlineSpan Function(MatchCandidate candidate) spanBuilder;
  final Map<String, dynamic>? Function(MatchCandidate candidate)? validator;

  @override
  List<MatchResult> findMatches(MatchingContext context) {
    final matches = <MatchResult>[];
    final allMatches = pattern.allMatches(context.fullText);

    for (final match in allMatches) {
      final candidate = MatchCandidate(
        context: context,
        start: match.start,
        end: match.end,
        text: match.group(0)!,
      );

      Map<String, dynamic> data = const {};

      if (validator != null) {
        final validationResult = validator!(candidate);
        if (validationResult == null) continue; // Skip invalid matches
        data = validationResult;
      }

      matches.add(
        MatchResult(
          start: match.start,
          end: match.end,
          text: match.group(0)!,
          priority: priority,
          data: data,
        ),
      );
    }

    return matches;
  }

  @override
  InlineSpan buildSpan(MatchResult match, MatchingContext context) {
    final candidate = MatchCandidate(
      context: context,
      start: match.start,
      end: match.end,
      text: match.text,
      data: match.data,
    );
    return spanBuilder(candidate);
  }
}
