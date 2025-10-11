// Dart imports:
import 'dart:convert';

// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../router.dart';
import '../../../selected_tags/tag.dart';

class SearchParams extends Equatable {
  const SearchParams({
    this.query,
    this.tags,
    this.page,
    this.scrollPosition,
    this.queryType,
    this.fromSearchBar,
    this.tagCategories,
  });

  factory SearchParams.fromUri(Uri uri) {
    final params = uri.queryParameters;
    final tagCategories = _parseTagCategories(params['tag_categories']);

    return SearchParams(
      query: params[kInitialQueryKey],
      tags: switch (params['tags']) {
        final tags? => _buildTagSetWithCategories(tags, tagCategories),
        _ => null,
      },
      page: int.tryParse(params['page'] ?? ''),
      scrollPosition: int.tryParse(params['position'] ?? ''),
      queryType: parseQueryType(params['query_type']),
      fromSearchBar: switch (params['from_search_bar']) {
        'true' => true,
        'false' => false,
        _ => null,
      },
      tagCategories: tagCategories,
    );
  }

  final String? query;
  final SearchTagSet? tags;
  final int? page;
  final int? scrollPosition;
  final QueryType? queryType;
  final bool? fromSearchBar;
  final Map<String, String>? tagCategories;

  Map<String, String> toQueryParams() {
    final categories = _extractTagCategories(tags);

    return {
      kInitialQueryKey: ?query,
      'tags': ?tags?.toString(),
      'page': ?page?.toString(),
      'position': ?scrollPosition?.toString(),
      'query_type': ?queryType?.name,
      'from_search_bar': ?fromSearchBar?.toString(),
      'tag_categories': ?categories != null && categories.isNotEmpty
          ? jsonEncode(categories)
          : null,
    };
  }

  @override
  List<Object?> get props => [
    query,
    tags,
    page,
    scrollPosition,
    queryType,
    fromSearchBar,
    tagCategories,
  ];

  static Map<String, String>? _extractTagCategories(SearchTagSet? tagSet) {
    if (tagSet == null || tagSet.isEmpty) return null;

    final categories = <String, String>{};

    for (final tag in tagSet.tags) {
      switch (tag.category) {
        case final category? when category.isNotEmpty:
          categories[tag.originalTag] = category;
      }
    }

    return categories.isEmpty ? null : categories;
  }

  static Map<String, String>? _parseTagCategories(String? json) {
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

      return categories.isEmpty ? null : categories;
    } catch (e) {
      return null;
    }
  }

  static SearchTagSet? _buildTagSetWithCategories(
    String tags,
    Map<String, String>? categories,
  ) {
    final tagSet = SearchTagSet();
    final tagList = queryAsList(tags);

    for (final tagString in tagList) {
      final category = categories?[tagString];

      tagSet.addTag(
        TagSearchItem.fromString(
          tagString,
          category: category,
        ),
      );
    }

    return tagSet;
  }
}
