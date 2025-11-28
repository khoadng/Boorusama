// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'common.dart';
import 'finder.dart';
import 'location.dart';
import 'progress.dart';
import 'target.dart';

typedef _NextPageData = ({int page, List<PageFinderTarget> items});

class _SearchState {
  const _SearchState({
    required this.requestsCounter,
    required this.perPage,
    required this.expectedPage,
    required this.visitedPages,
  });

  const _SearchState.initial()
    : requestsCounter = 0,
      perPage = const [],
      expectedPage = 1,
      visitedPages = const {};

  final int requestsCounter;
  final List<int> perPage;
  final int expectedPage;
  final Set<int> visitedPages;

  _SearchState copyWith({
    int? requestsCounter,
    List<int>? perPage,
    int? expectedPage,
    Set<int>? visitedPages,
  }) => _SearchState(
    requestsCounter: requestsCounter ?? this.requestsCounter,
    perPage: perPage ?? this.perPage,
    expectedPage: expectedPage ?? this.expectedPage,
    visitedPages: visitedPages ?? this.visitedPages,
  );

  _SearchState incrementRequests() =>
      copyWith(requestsCounter: requestsCounter + 1);

  _SearchState addPerPage(int delta) => copyWith(perPage: [...perPage, delta]);

  _SearchState updateExpectedPage(int page) => copyWith(expectedPage: page);

  _SearchState markPageVisited(int page) =>
      copyWith(visitedPages: {...visitedPages, page});

  double get averagePerPage =>
      perPage.isEmpty ? 0 : perPage.reduce((a, b) => a + b) / perPage.length;
}

class InterpolationPageFinder extends BasePageFinder {
  InterpolationPageFinder({
    required super.repository,
    required super.searchChunkSize,
    required super.userChunkSize,
    super.onProgress,
    super.fetchDelay,
  });

  var _state = const _SearchState.initial();

  @override
  Future<PageLocation?> findPage(PaginationSnapshot snapshot) async {
    resetRequestsCounter();
    _state = const _SearchState(
      requestsCounter: 0,
      perPage: [],
      expectedPage: 1,
      visitedPages: {},
    );

    if (snapshot.historicalPage != null &&
        snapshot.historicalChunkSize != null) {
      final startingPage = _calculateStartingPage(snapshot);
      _state = _state.updateExpectedPage(startingPage);
    }

    log(
      '[InterpolationPageFinder] Finding item #${snapshot.targetId} (starting at page ${_state.expectedPage})',
    );

    try {
      final result = await _findRecursive(snapshot, null);
      log(
        '[InterpolationPageFinder] Success: p.${result.page}[${result.index}] in $requestsCounter requests',
      );
      onProgress?.call(
        PageFinderCompletedProgress(
          location: result,
          totalRequests: requestsCounter,
        ),
      );
      return result;
    } on PageFinderBeyondLimitException {
      // Let pagination limit exceptions propagate to caller
      // so they can handle it (e.g., fall back to ID range continuation)
      rethrow;
    } on PageFinderServerException {
      // Let server exceptions propagate to caller
      rethrow;
    } catch (e) {
      log('[InterpolationPageFinder] Failed: $e');
      onProgress?.call(PageFinderFailedProgress(e));
      return null;
    }
  }

  int _calculateStartingPage(PaginationSnapshot snapshot) {
    final chunkSizeRatio = userChunkSize / snapshot.historicalChunkSize!;
    final estimatedPage = (snapshot.historicalPage! * chunkSizeRatio).round();

    log(
      '  [adjust] Historical: p.${snapshot.historicalPage} → p.$estimatedPage (ratio: ${chunkSizeRatio.toStringAsFixed(2)})',
    );
    return estimatedPage.clamp(1, double.infinity).toInt();
  }

  Future<PageLocation> _findRecursive(
    PaginationSnapshot snapshot,
    List<PageFinderTarget>? currentPageItems,
  ) async {
    final clampedPage = _state.expectedPage.clamp(0, double.infinity).toInt();
    _state = _state.updateExpectedPage(clampedPage);

    // Check if we've visited this page before
    if (_state.visitedPages.contains(_state.expectedPage)) {
      log(
        '  [loop detected] Already visited p.${_state.expectedPage}, target not found',
      );
      throw PageFinderEmptyPageException();
    }
    _state = _state.markPageVisited(_state.expectedPage);

    final items =
        currentPageItems ?? await fetchItems(snapshot, _state.expectedPage);

    if (items.isEmpty) throw PageFinderEmptyPageException();

    final first = items.first.id;
    final last = items.last.id;

    onProgress?.call(
      PageFinderSearchingProgress(
        currentPage: _state.expectedPage,
        requestCount: requestsCounter,
        targetId: snapshot.targetId,
      ),
    );

    final inRange = first >= snapshot.targetId && last <= snapshot.targetId;

    if (inRange) {
      final index = getIndexOfItem(snapshot.targetId, items);
      log(
        '  [match] p.${_state.expectedPage}: [$first - $last] target at index $index',
      );
      return makeReply(snapshot, items, _state.expectedPage);
    }

    if (kDebugMode) {
      final targetId = snapshot.targetId;
      final direction = targetId > first ? 'too new' : 'too old';
      final distance = (targetId > first ? targetId - first : last - targetId)
          .abs();
      log(
        '  [scan] p.${_state.expectedPage}: [$first - $last] target #$targetId is $direction (${distance > 1000 ? '${(distance / 1000).toStringAsFixed(1)}k' : distance} items away)',
      );
    }

    final delta = first - last;
    _state = _state.addPerPage(delta);
    final avg = _state.averagePerPage;

    final nextPageData = await _getNextPageData(snapshot, first, avg);
    _state = _state.updateExpectedPage(nextPageData.page);
    return _findRecursive(snapshot, nextPageData.items);
  }

  Future<_NextPageData> _getNextPageData(
    PaginationSnapshot snapshot,
    int curFirstId,
    double avgDelta, {
    int emptyPageRetries = 0,
  }) async {
    final delta = curFirstId - snapshot.targetId;
    var nextPage = (_state.expectedPage + delta / avgDelta).toInt();

    // Prevent infinite loop when delta/avgDelta rounds to 0
    // This happens when the target is very close but not on the current page
    if (nextPage == _state.expectedPage) {
      nextPage = delta > 0 ? _state.expectedPage + 1 : _state.expectedPage - 1;
    }

    if (kDebugMode) {
      final pagesAway = (delta / avgDelta).round();
      log(
        '  [jump] Target is ~$pagesAway pages away (${delta.abs()} items ÷ ${avgDelta.toStringAsFixed(0)}/page) → trying p.$nextPage',
      );
    }

    if (nextPage < 0) throw PageFinderInvalidPageException();

    final nextItems = await fetchItems(snapshot, nextPage);
    if (nextItems.isEmpty) {
      // Empty page likely means we're beyond available data
      // Try one smaller jump, then give up
      if (emptyPageRetries >= 1) throw PageFinderEmptyPageException();
      return _getNextPageData(
        snapshot,
        curFirstId,
        avgDelta / 2,
        emptyPageRetries: emptyPageRetries + 1,
      );
    }

    return (page: nextPage, items: nextItems);
  }
}
