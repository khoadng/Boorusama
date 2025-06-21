import 'matching_context.dart';

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
}
