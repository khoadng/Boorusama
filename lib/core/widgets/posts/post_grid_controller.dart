// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/core/feats/settings/settings.dart';
import 'package:boorusama/dart.dart';

typedef ItemFetcher<T> = Future<List<T>> Function(int page);
typedef ItemRefresher<T> = Future<List<T>> Function();

class PostGridController<T> extends ChangeNotifier {
  PostGridController({
    required this.fetcher,
    required this.refresher,
    required this.keySelector,
    this.debounceDuration = const Duration(milliseconds: 500),
    PageMode pageMode = PageMode.infinite,
  }) : _pageMode = pageMode;

  final ItemFetcher<T> fetcher;
  final ItemRefresher<T> refresher;
  final int Function(T item) keySelector;
  PageMode _pageMode;

  List<T> _items = [];
  Set<int> _keys = {};
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _refreshing = false;

  Iterable<T> get items => _items;

  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get refreshing => _refreshing;
  int get page => _page;

  Timer? _debounceTimer;
  final Duration debounceDuration;

  // Getter for _pageMode
  PageMode get pageMode => _pageMode;

  // Set the page mode and reset the state
  void setPageMode(PageMode? newPageMode) {
    if (newPageMode == null || _pageMode == newPageMode) return;

    _pageMode = newPageMode;

    _hasMore = true;
    _refreshing = false;
    _loading = false;
    if (newPageMode == PageMode.infinite) {
      _clear();
      _page = 1;
      refresh();
    } else {
      jumpToPage(_page);
    }

    notifyListeners();
  }

  // Refreshes the list
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    _page = 1;
    notifyListeners();

    final newItems = await refresher();
    _addAll(newItems);
    _hasMore = newItems.isNotEmpty;
    _refreshing = false;
    notifyListeners();
  }

  // Loads more items
  Future<void> fetchMore() async {
    if (_loading ||
        !_hasMore ||
        (_debounceTimer != null && _debounceTimer!.isActive)) return;

    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () async {
      _loading = true;
      if (_pageMode == PageMode.infinite) {
        _page++;
      }
      notifyListeners();

      final newItems = await fetcher(_page);
      _hasMore = newItems.isNotEmpty;
      if (_hasMore) {
        _addAll(newItems);
      }
      _loading = false;
      notifyListeners();
    });
  }

  // Jump to a specific page without knowing the total pages and allowing page skips
  Future<void> jumpToPage(int targetPage) async {
    if (_pageMode != PageMode.paginated ||
        _loading ||
        _refreshing ||
        targetPage < 1) {
      return;
    }

    _page = targetPage;
    _clear();
    _refreshing = true;
    notifyListeners();

    final newItems = await fetcher(_page);
    _hasMore = newItems.isNotEmpty;
    if (_hasMore) {
      _addAll(newItems);
    }
    _refreshing = false;
    notifyListeners();
  }

  Future<void> goToPreviousPage() async {
    if (hasPreviousPage()) {
      await jumpToPage(_page - 1);
    }
  }

  Future<void> goToNextPage() async {
    if (hasNextPage()) {
      await jumpToPage(_page + 1);
    }
  }

  // Check if there is a previous page
  bool hasPreviousPage() {
    // Check if the current mode is paginated and there is a previous page
    return _pageMode == PageMode.paginated && _page > 1;
  }

  // Check if there is a next page
  bool hasNextPage() {
    // Check if the current mode is paginated and there are more items to fetch
    return _pageMode == PageMode.paginated && _hasMore;
  }

  // Moves and inserts an item
  void moveAndInsert({
    required int fromIndex,
    required int toIndex,
    void Function()? onSuccess,
  }) {
    final data = [..._items];
    data.reorder(fromIndex, toIndex);
    onSuccess?.call();

    _items = data;
    notifyListeners();
  }

  void remove(List<int> postIds, int Function(T item) itemIdExtractor) {
    final data = [..._items]
      ..removeWhere((e) => postIds.contains(itemIdExtractor(e)));

    // remove keys
    _keys = data.map((e) => itemIdExtractor(e)).toSet();

    _items = data;
    notifyListeners();
  }

  void _addAll(List<T> newItems) {
    for (final item in newItems) {
      final key = keySelector(item);
      if (!_keys.contains(key)) {
        _items.add(item);
        _keys.add(key);
      }
    }
    notifyListeners();
  }

  void _clear() {
    _items.clear();
    _keys.clear();
    notifyListeners();
  }
}
