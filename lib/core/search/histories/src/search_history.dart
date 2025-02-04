// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

enum QueryType {
  /// Example: `tag1 -tag2`
  simple,

  /// Example: ["tag1", "tag2", "tag3"]
  list,
}

QueryType? parseQueryType(String? type) => switch (type) {
      'simple' => QueryType.simple,
      'list' => QueryType.list,
      _ => null
    };

class SearchHistory extends Equatable {
  const SearchHistory({
    required this.query,
    required this.createdAt,
    required this.updatedAt,
    required this.searchCount,
    required this.queryType,
    required this.booruTypeName,
    required this.siteUrl,
  });

  factory SearchHistory.now(
    String query,
    QueryType queryType, {
    required String booruTypeName,
    required String siteUrl,
  }) =>
      SearchHistory(
        query: query,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        searchCount: 0,
        queryType: queryType,
        booruTypeName: booruTypeName,
        siteUrl: siteUrl,
      );

  final String query;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int searchCount;
  final QueryType? queryType;
  final String booruTypeName;
  final String siteUrl;

  SearchHistory copyWith({
    String? query,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? searchCount,
    QueryType? Function()? queryType,
    String? booruTypeName,
    String? siteUrl,
  }) =>
      SearchHistory(
        query: query ?? this.query,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        searchCount: searchCount ?? this.searchCount,
        queryType: queryType != null ? queryType() : this.queryType,
        booruTypeName: booruTypeName ?? this.booruTypeName,
        siteUrl: siteUrl ?? this.siteUrl,
      );

  @override
  List<Object?> get props => [
        query,
        createdAt,
        updatedAt,
        searchCount,
        queryType,
        booruTypeName,
        siteUrl,
      ];
}

extension SearchHistoryX on SearchHistory {
  List<String> queryAsList() {
    if (queryType != QueryType.list) return [];

    final json = jsonDecode(query);

    if (json is! List) return [];

    try {
      return [for (final tag in json) tag as String];
    } catch (e) {
      return [];
    }
  }
}
