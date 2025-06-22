class MatchResult {
  const MatchResult({
    required this.start,
    required this.end,
    required this.text,
    required this.priority,
    this.data = const {},
  });

  const MatchResult.empty()
    : start = 0,
      end = 0,
      text = '',
      priority = 0,
      data = const {};

  final int start;
  final int end;
  final String text;
  final int priority; // Higher priority wins conflicts
  final Map<String, dynamic> data; // Matcher-specific data

  int get length => end - start;

  factory MatchResult.fromRegexMatch(
    RegExpMatch match,
    int priority, {
    Map<String, dynamic> data = const {},
  }) {
    return MatchResult(
      start: match.start,
      end: match.end,
      text: match.group(0)!,
      priority: priority,
      data: data,
    );
  }

  MatchResult copyWith({
    int? start,
    int? end,
    String? text,
    int? priority,
    Map<String, dynamic>? data,
  }) {
    return MatchResult(
      start: start ?? this.start,
      end: end ?? this.end,
      text: text ?? this.text,
      priority: priority ?? this.priority,
      data: data ?? this.data,
    );
  }
}
