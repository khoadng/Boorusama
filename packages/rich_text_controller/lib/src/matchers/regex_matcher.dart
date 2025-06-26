import '../match_candidate.dart';
import '../match_result.dart';
import '../matching_context.dart';
import 'function_matcher.dart';

class RegexMatcher extends FunctionMatcher {
  RegexMatcher({
    required RegExp pattern,
    required super.spanBuilder,
    super.validator,
    super.priority,
    super.options,
  }) : super(
         finder: (context) => _regexFinder(
           pattern,
           context,
           validator,
           priority,
         ),
       );

  static List<MatchResult> _regexFinder(
    RegExp pattern,
    MatchingContext context,
    MatchValidator? validator,
    int priority,
  ) {
    final matches = <MatchResult>[];
    final allMatches = pattern.allMatches(context.fullText);

    for (final match in allMatches) {
      final candidate = MatchCandidate.fromRegexMatch(match, context);

      var data = const <String, dynamic>{};

      if (validator != null) {
        final validationResult = validator(candidate);
        if (validationResult == null) continue; // Skip invalid matches
        data = validationResult;
      }

      matches.add(MatchResult.fromRegexMatch(match, priority, data: data));
    }

    return matches;
  }
}
