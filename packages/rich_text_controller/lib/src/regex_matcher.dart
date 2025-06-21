import 'package:flutter/widgets.dart';

import 'match_candidate.dart';
import 'match_result.dart';
import 'matching_context.dart';
import 'text_matcher.dart';

class RegexMatcher extends TextMatcher {
  RegexMatcher({
    required RegExp pattern,
    required this.spanBuilder,
    this.validator,
    super.priority,
    super.options,
  }) : _pattern = pattern;

  final RegExp _pattern;
  final InlineSpan Function(MatchCandidate candidate) spanBuilder;
  final Map<String, dynamic>? Function(MatchCandidate candidate)? validator;

  @override
  List<MatchResult> findMatches(MatchingContext context) {
    final matches = <MatchResult>[];
    final allMatches = _pattern.allMatches(context.fullText);

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

    final userSpan = spanBuilder(candidate);

    // Auto-add padding for WidgetSpan
    if (userSpan is! TextSpan) {
      return TextSpan(
        children: [
          userSpan,
          // Add zero-width spaces to fix cursor positioning
          TextSpan(text: '\u200b' * (match.text.length - 1)),
        ],
      );
    }

    return userSpan;
  }
}
