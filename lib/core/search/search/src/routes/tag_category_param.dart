// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../selected_tags/search_tag_set.dart';

class TagCategoryParam extends Equatable {
  const TagCategoryParam(this._categories);

  factory TagCategoryParam.fromTagSet(SearchTagSet? tagSet) {
    if (tagSet == null || tagSet.isEmpty) return const TagCategoryParam({});

    final categories = <String, String>{};

    for (final tag in tagSet.tags) {
      switch (tag.category) {
        case final category? when category.isNotEmpty:
          categories[tag.originalTag] = category;
      }
    }

    return TagCategoryParam(categories);
  }

  static TagCategoryParam? tryParse(String? json) {
    if (json == null || json.isEmpty) return null;

    try {
      final decoded = jsonDecode(json);

      if (decoded is! Map) return null;

      final categories = <String, String>{};

      for (final entry in decoded.entries) {
        final key = entry.key;
        final value = entry.value;

        if (key is String && value is String) {
          categories[key] = value;
        }
      }

      return categories.isEmpty ? null : TagCategoryParam(categories);
    } catch (e) {
      return null;
    }
  }

  final Map<String, String> _categories;

  String? operator [](String tag) => _categories[tag];

  String? toJson() {
    if (_categories.isEmpty) return null;

    return jsonEncode(_categories);
  }

  @override
  List<Object?> get props => [_categories];
}
