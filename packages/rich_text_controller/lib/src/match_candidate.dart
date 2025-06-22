import 'matching_context.dart';
import 'match_result.dart';

class MatchCandidate {
  const MatchCandidate({
    required this.context,
    required this.start,
    required this.end,
    required this.text,
    this.data = const {},
  });

  final MatchingContext context;
  final int start;
  final int end;
  final String text;
  final Map<String, dynamic> data;

  factory MatchCandidate.fromMatchResult(
    MatchResult match,
    MatchingContext context,
  ) {
    return MatchCandidate(
      context: context,
      start: match.start,
      end: match.end,
      text: match.text,
      data: match.data,
    );
  }

  factory MatchCandidate.fromRegexMatch(
    RegExpMatch match,
    MatchingContext context, {
    Map<String, dynamic> data = const {},
  }) {
    return MatchCandidate(
      context: context,
      start: match.start,
      end: match.end,
      text: match.group(0)!,
      data: data,
    );
  }
}
