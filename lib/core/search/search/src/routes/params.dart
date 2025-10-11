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
  });

  factory SearchParams.fromUri(Uri uri) {
    final params = uri.queryParameters;

    return SearchParams(
      query: params[kInitialQueryKey],
      tags: switch (params['tags']) {
        final tags? => SearchTagSet.fromString(tags),
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
    );
  }

  final String? query;
  final SearchTagSet? tags;
  final int? page;
  final int? scrollPosition;
  final QueryType? queryType;
  final bool? fromSearchBar;

  Map<String, String> toQueryParams() => {
    kInitialQueryKey: ?query,
    'tags': ?tags?.toString(),
    'page': ?page?.toString(),
    'position': ?scrollPosition?.toString(),
    'query_type': ?queryType?.name,
    'from_search_bar': ?fromSearchBar?.toString(),
  };

  @override
  List<Object?> get props => [
    query,
    tags,
    page,
    scrollPosition,
    queryType,
    fromSearchBar,
  ];
}
