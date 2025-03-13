// Dart imports:
import 'dart:convert';

mixin QueryTypeMixin {
  String get query;
  QueryType? get queryType;

  List<String> queryAsList() {
    if (queryType != QueryType.list) return [];

    final decoded = jsonDecode(query);
    if (decoded is! List) return [];
    try {
      return [for (final tag in decoded) tag as String];
    } catch (_) {
      return [];
    }
  }

  static QueryType? parseQueryType(String? type) {
    if (type == 'simple') return QueryType.simple;
    if (type == 'list') return QueryType.list;
    return null;
  }
}

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
