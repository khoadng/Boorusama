// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:collection/collection.dart';

mixin QueryTypeMixin {
  String get query;
  QueryType? get queryType;

  List<String> queryAsList() {
    if (queryType != QueryType.list) return [];

    try {
      final decoded = jsonDecode(query);
      if (decoded is! List) return [];
      return [for (final tag in decoded) tag as String];
    } catch (_) {
      return [];
    }
  }
}

enum QueryType {
  /// Example: `tag1 -tag2`
  simple('simple'),

  /// Example: ["tag1", "tag2", "tag3"]
  list('list');

  const QueryType(this.type);

  final String type;

  static QueryType? fromString(String? type) {
    if (type == null) return null;

    return QueryType.values.firstWhereOrNull(
      (e) => e.type == type,
    );
  }

  @override
  String toString() => type;
}

QueryType? parseQueryType(String? type) => QueryType.fromString(type);
