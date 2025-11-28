// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'finder.dart';
import 'location.dart';
import 'progress.dart';
import 'repo.dart';
import 'target.dart';

abstract class BasePageFinder implements PageFinder {
  BasePageFinder({
    required this.repository,
    required this.searchChunkSize,
    required this.userChunkSize,
    this.onProgress,
    this.fetchDelay,
  });

  final PageFinderRepository repository;
  final int searchChunkSize;
  final int userChunkSize;
  final void Function(PageFinderProgress progress)? onProgress;
  final Duration? fetchDelay;

  var _requestsCounter = 0;

  int get requestsCounter => _requestsCounter;

  void resetRequestsCounter() {
    _requestsCounter = 0;
  }

  Future<List<PageFinderTarget>> fetchItems(
    PaginationSnapshot snapshot,
    int page,
  ) async {
    _requestsCounter++;
    onProgress?.call(
      PageFinderFetchingProgress(
        page: page,
        requestNumber: _requestsCounter,
      ),
    );
    final result = await repository.fetchItems(
      PageFinderQuery(
        tags: snapshot.tags,
        page: page,
        limit: searchChunkSize,
      ),
    );

    if (fetchDelay case final d?) {
      await Future.delayed(d);
    }

    return switch (result) {
      PageFinderSuccess(:final items) => items,
      PageFinderPaginationLimitReached(:final maxPage, :final requestedPage) =>
        throw PageFinderBeyondLimitException(
          maxPage: maxPage,
          requestedPage: requestedPage,
        ),
      PageFinderServerError(:final message) => throw PageFinderServerException(
        message,
      ),
      PageFinderEmptyPage() => <PageFinderTarget>[],
    };
  }

  PageLocation makeReply(
    PaginationSnapshot snapshot,
    List<PageFinderTarget> currentPageItems,
    int page,
  ) {
    final idx = getIndexOfItem(snapshot.targetId, currentPageItems);

    if (userChunkSize == searchChunkSize) {
      return PageLocation(page: page, index: idx);
    }

    return adjustPageForUserChunkSize(page, idx);
  }

  PageLocation adjustPageForUserChunkSize(int searchPage, int searchIndex) {
    final absolutePosition = (searchPage - 1) * searchChunkSize + searchIndex;
    final userPage = (absolutePosition ~/ userChunkSize) + 1;
    final userIndex = absolutePosition % userChunkSize;

    log(
      '  [remap] Chunk size adjusted: p.$searchPage[$searchIndex] → p.$userPage[$userIndex]',
    );

    return PageLocation(page: userPage, index: userIndex);
  }

  int getIndexOfItem(int targetId, List<PageFinderTarget> currentPage) {
    var skip = 0;

    for (final item in currentPage) {
      if (item.id == targetId) {
        return skip;
      }

      if (item.id < targetId) {
        break;
      }

      skip++;
    }

    return skip;
  }

  void log(String message) {
    if (kDebugMode) {
      debugPrint(message);
    }
  }
}
