class SearchHistory {
  SearchHistory({
    required this.query,
    required this.createdAt,
  });
  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(
        query: json['query'],
        createdAt: DateTime.parse(json['created_at']),
      );

  factory SearchHistory.now(String query) => SearchHistory(
        query: query,
        createdAt: DateTime.now(),
      );

  final String query;
  final DateTime createdAt;

  Map<String, dynamic> toJson() => {
        'query': query,
        'created_at': createdAt.toIso8601String(),
      };
}
