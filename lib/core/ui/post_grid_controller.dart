// Flutter imports:
import 'package:flutter/foundation.dart';

typedef ItemFetcher<T> = Future<List<T>> Function(int page);
typedef ItemRefresher<T> = Future<List<T>> Function();

class PostGridController<T> extends ChangeNotifier {
  PostGridController({
    required this.fetcher,
    required this.refresher,
  });

  final ItemFetcher<T> fetcher;
  final ItemRefresher<T> refresher;

  List<T> _items = [];
  int _page = 1;
  bool _hasMore = true;
  bool _loading = false;
  bool _refreshing = false;

  List<T> get items => _items;

  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get refreshing => _refreshing;

  // Refreshes the list
  Future<void> refresh() async {
    if (_refreshing) return;
    _refreshing = true;
    _page = 1;
    notifyListeners();

    final newItems = await refresher();
    _items = newItems;
    _hasMore = newItems.isNotEmpty;
    _refreshing = false;
    notifyListeners();
  }

  // Loads more items
  Future<void> fetchMore() async {
    if (_loading || !_hasMore) return;
    _loading = true;
    _page++;
    notifyListeners();

    final newItems = await fetcher(_page);
    _hasMore = newItems.isNotEmpty;
    if (_hasMore) {
      _items.addAll(newItems);
    }
    _loading = false;
    notifyListeners();
  }

  // Moves and inserts an item
  void moveAndInsert({
    required int fromIndex,
    required int toIndex,
    void Function()? onSuccess,
  }) {
    final data = [..._items];
    final item = data.removeAt(fromIndex);
    data.insert(toIndex, item);
    onSuccess?.call();

    _items = data;
    notifyListeners();
  }

  void remove(List<int> postIds, int Function(T item) itemIdExtractor) {
    final data = [..._items]
      ..removeWhere((e) => postIds.contains(itemIdExtractor(e)));

    _items = data;
    notifyListeners();
  }
}
