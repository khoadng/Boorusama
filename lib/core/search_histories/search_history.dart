// Package imports:
import 'package:equatable/equatable.dart';

enum QueryType {
  /// Example: `tag1 -tag2`
  simple,

  /// Same as simple but let the app know that the query is raw
  /// Example: `tag1 {tag2 ~ tag3}`
  raw,

  /// Example: ["tag1", "tag2", "tag3"]
  list,
}

QueryType? parseQueryType(String? type) => switch (type) {
      'simple' => QueryType.simple,
      'raw' => QueryType.raw,
      'list' => QueryType.list,
      _ => null
    };

class SearchHistory extends Equatable {
  const SearchHistory({
    required this.query,
    required this.createdAt,
    required this.searchCount,
    required this.queryType,
  });
  factory SearchHistory.fromJson(Map<String, dynamic> json) => SearchHistory(
        query: json['query'],
        createdAt: DateTime.parse(json['created_at']),
        searchCount: json['search_count'],
        queryType: parseQueryType(json['type']),
      );

  factory SearchHistory.now(String query, QueryType queryType) => SearchHistory(
        query: query,
        createdAt: DateTime.now(),
        searchCount: 0,
        queryType: queryType,
      );

  final String query;
  final DateTime createdAt;
  final int searchCount;
  final QueryType? queryType;

  SearchHistory copyWith({
    String? query,
    DateTime? createdAt,
    int? searchCount,
  }) =>
      SearchHistory(
        query: query ?? this.query,
        createdAt: createdAt ?? this.createdAt,
        searchCount: searchCount ?? this.searchCount,
        queryType: queryType,
      );

  Map<String, dynamic> toJson() => {
        'query': query,
        'created_at': createdAt.toIso8601String(),
        'search_count': searchCount,
        'type': queryType?.name,
      };

  @override
  List<Object?> get props => [query, createdAt, searchCount, queryType];
}
