import 'package:equatable/equatable.dart';

class SearchHistory extends Equatable {
  const SearchHistory({
    required this.query,
    required this.createdAt,
    required this.searchCount,
  });
  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(
        query: json['query'],
        createdAt: DateTime.parse(json['created_at']),
        searchCount: json['search_count'],
      );

  factory SearchHistory.now(String query) => SearchHistory(
        query: query,
        createdAt: DateTime.now(),
        searchCount: 0,
      );

  final String query;
  final DateTime createdAt;
  final int searchCount;

  SearchHistory copyWith({
    String? query,
    DateTime? createdAt,
    int? searchCount,
  }) =>
      SearchHistory(
        query: query ?? this.query,
        createdAt: createdAt ?? this.createdAt,
        searchCount: searchCount ?? this.searchCount,
      );

  Map<String, dynamic> toJson() => {
        'query': query,
        'created_at': createdAt.toIso8601String(),
        'search_count': searchCount,
      };

  @override
  List<Object?> get props => [query, createdAt, searchCount];
}
