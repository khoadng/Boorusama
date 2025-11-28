// Package imports:
import 'package:equatable/equatable.dart';

// Project imports:
import 'target.dart';

sealed class PageFinderResult {}

class PageFinderSuccess extends PageFinderResult {
  PageFinderSuccess({required this.items});
  final List<PageFinderTarget> items;
}

class PageFinderPaginationLimitReached extends PageFinderResult {
  PageFinderPaginationLimitReached({
    required this.maxPage,
    required this.requestedPage,
  });
  final int maxPage;
  final int requestedPage;
}

class PageFinderServerError extends PageFinderResult {
  PageFinderServerError({required this.message});
  final String message;
}

class PageFinderEmptyPage extends PageFinderResult {}

class PageFinderQuery extends Equatable {
  const PageFinderQuery({
    required this.tags,
    required this.page,
    required this.limit,
  });

  final String tags;
  final int page;
  final int limit;

  @override
  List<Object?> get props => [tags, page, limit];
}

abstract interface class PageFinderRepository {
  Future<PageFinderResult> fetchItems(
    PageFinderQuery query,
  );
}

typedef PageFinderHandler =
    Future<PageFinderResult> Function(PageFinderQuery query);

class PageFinderBuilder implements PageFinderRepository {
  PageFinderBuilder({
    required this.fetch,
  });

  final PageFinderHandler fetch;

  @override
  Future<PageFinderResult> fetchItems(
    PageFinderQuery query,
  ) => fetch(query);
}
