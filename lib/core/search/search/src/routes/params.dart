// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import '../../../../router.dart';
import '../../../selected_tags/types.dart';
import 'tag_category_param.dart';

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
    final tagCategories = TagCategoryParam.tryParse(params['tag_categories']);

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
  final TagCategoryParam? tagCategories;

  Map<String, String> toQueryParams() {
    final categories = TagCategoryParam.fromTagSet(tags);

    return {
      kInitialQueryKey: ?query,
      'tags': ?tags?.toString(),
      'page': ?page?.toString(),
      'position': ?scrollPosition?.toString(),
      'query_type': ?queryType?.name,
      'from_search_bar': ?fromSearchBar?.toString(),
      'tag_categories': ?categories.toJson(),
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

  static SearchTagSet? _buildTagSetWithCategories(
    String tags,
    TagCategoryParam? categories,
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
