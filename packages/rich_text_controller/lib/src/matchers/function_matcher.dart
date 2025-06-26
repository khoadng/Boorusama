import 'package:flutter/widgets.dart';

import '../match_candidate.dart';
import '../match_result.dart';
import '../matching_context.dart';
import '../text_matcher.dart';

typedef MatchFinder = List<MatchResult> Function(MatchingContext context);
typedef SpanBuilder = InlineSpan Function(MatchCandidate candidate);
typedef MatchValidator =
    Map<String, dynamic>? Function(MatchCandidate candidate);

class FunctionMatcher extends TextMatcher {
  FunctionMatcher({
    required this.finder,
    required this.spanBuilder,
    this.validator,
    super.priority,
    super.options,
  });

  final MatchFinder finder;
  final SpanBuilder spanBuilder;
  final MatchValidator? validator;

  @override
  List<MatchResult> findMatches(MatchingContext context) {
    final matches = finder(context);

    return switch (validator) {
      MatchValidator validator =>
        matches
            .where(
              (match) =>
                  validator(MatchCandidate.fromMatchResult(match, context)) !=
                  null,
            )
            .toList(),
      null => matches,
    };
  }

  @override
  InlineSpan buildSpan(MatchResult match, MatchingContext context) {
    final candidate = MatchCandidate.fromMatchResult(match, context);

    final userSpan = spanBuilder(candidate);

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

  @override
  TextSelection adjustSelection(
    TextSelection selection,
    MatchingContext context,
  ) {
    if (!options.jumpOver) return selection;

    if (selection.baseOffset != selection.extentOffset) return selection;

    final cursor = selection.baseOffset;

    if (cursor <= 0 || cursor >= context.fullText.length) {
      return selection;
    }

    final matches = findMatches(context);

    if (matches.isEmpty) return selection;

    // Pick the closest match to the cursor
    final match = matches.reduce(
      (a, b) => (a.start - cursor).abs() < (b.start - cursor).abs() ? a : b,
    );

    if (match.start <= cursor && match.end >= cursor) {
      final distanceToStart = (cursor - match.start).abs();
      final distanceToEnd = (cursor - match.end).abs();

      // If one side is 1, prefer the other side
      if (distanceToEnd == 1) {
        return TextSelection.collapsed(offset: match.start);
      } else if (distanceToStart == 1) {
        return TextSelection.collapsed(offset: match.end);
      }
    }

    return selection;
  }
}
