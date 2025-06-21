class MatchResult {
  const MatchResult({
    required this.start,
    required this.end,
    required this.text,
    required this.priority,
    this.data = const {},
  });

  final int start;
  final int end;
  final String text;
  final int priority; // Higher priority wins conflicts
  final Map<String, dynamic> data; // Matcher-specific data

  int get length => end - start;
}
