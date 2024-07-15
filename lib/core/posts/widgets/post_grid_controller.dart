// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import 'package:boorusama/core/posts/posts.dart';
import 'package:boorusama/core/settings/settings.dart';
import 'package:boorusama/dart.dart';

const _kFirstPage = 1;
const _kJumpStep = 1;

typedef ItemFetcher<T extends Post> = Future<PostResult<T>> Function(int page);
typedef ItemRefresher<T extends Post> = Future<PostResult<T>> Function();

extension TagCountX on Map<String, Set<int>> {
  int get totalNonDuplicatesPostCount => values.expand((e) => e).toSet().length;
}

class PostGridController<T extends Post> extends ChangeNotifier {
  PostGridController({
    required this.fetcher,
    required this.refresher,
    required this.blacklistedTagsFetcher,
    this.debounceDuration = const Duration(milliseconds: 500),
    PageMode pageMode = PageMode.infinite,
    this.blacklistedUrlsFetcher,
  }) : _pageMode = pageMode;

  final ItemFetcher<T> fetcher;
  final ItemRefresher<T> refresher;
  PageMode _pageMode;

  final Set<String> Function()? blacklistedUrlsFetcher;

  Set<String>? blacklistedTags;
  final Future<Set<String>> Function() blacklistedTagsFetcher;

  List<T> _items = [];
  List<T> _filteredItems = [];
  Set<int> _keys = {};
  int _page = _kFirstPage;
  bool _hasMore = true;
  bool _loading = false;
  bool _refreshing = false;

  int _total = 0;

  Iterable<T> get items => _filteredItems;

  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get refreshing => _refreshing;
  int get page => _page;
  int get total => _total;

  final ValueNotifier<int?> count = ValueNotifier(null);

  Timer? _debounceTimer;
  final Duration debounceDuration;

  // Getter for _pageMode
  PageMode get pageMode => _pageMode;

  final activeFilters = ValueNotifier<Map<String, bool>>({});
  final tagCounts = ValueNotifier<Map<String, Set<int>>>({});
  final hasBlacklist = ValueNotifier(false);

  Future<void> setBlacklistedTags(Set<String> tags) async {
    // check if the tags are the same
    if (blacklistedTags?.join(',') == tags.join(',')) return;

    final newTags = tags.toSet();
    blacklistedTags = newTags;

    tagCounts.value = await _count(_items, newTags);

    hasBlacklist.value = tagCounts.value.values.any((e) => e.isNotEmpty);
    activeFilters.value = {
      ...activeFilters.value,
      ...Map.fromIterable(tags, value: (_) => true),
    };
    await _filter();
    notifyListeners();
  }

  Future<void> enableTag(String tag) async {
    final data = {...activeFilters.value};
    data[tag] = true;
    activeFilters.value = data;

    await _filter();
    notifyListeners();
  }

  Future<void> disableTag(String tag) async {
    final data = {...activeFilters.value};
    data[tag] = false;
    activeFilters.value = data;

    await _filter();
    notifyListeners();
  }

  Future<void> enableAllTags() async {
    activeFilters.value =
        activeFilters.value.map((key, value) => MapEntry(key, true));

    await _filter();
    notifyListeners();
  }

  Future<void> disableAllTags() async {
    activeFilters.value =
        activeFilters.value.map((key, value) => MapEntry(key, false));

    await _filter();
    notifyListeners();
  }

  Future<Set<String>> _getBlacklistedTags() async {
    // lazy load blacklisted tags
    if (blacklistedTags == null) {
      final tags = await blacklistedTagsFetcher();

      blacklistedTags = tags;

      return tags;
    } else {
      return blacklistedTags!;
    }
  }

  Future<void> _filter() async {
    // filter using tagCounts and activeFilters
    final filteredItems = await __filter(
      _items,
      tagCounts.value,
      activeFilters.value,
      blacklistedUrlsFetcher != null ? blacklistedUrlsFetcher!() : {},
    );

    _filteredItems = filteredItems;
  }

  // Set the page mode and reset the state
  void setPageMode(PageMode? newPageMode) {
    if (newPageMode == null || _pageMode == newPageMode) return;

    _pageMode = newPageMode;

    _hasMore = true;
    _refreshing = false;
    _loading = false;
    if (newPageMode == PageMode.infinite) {
      _clear();
      _page = _kFirstPage;
      refresh();
    } else {
      jumpToPage(_page);
    }

    notifyListeners();
  }

  // Refreshes the list
  Future<void> refresh({
    bool maintainPage = false,
  }) async {
    if (_refreshing) return;
    _refreshing = true;
    _page = switch (_pageMode) {
      PageMode.infinite => _kFirstPage,
      PageMode.paginated => maintainPage ? _page : _kFirstPage,
    };
    notifyListeners();

    final newItems =
        await (_pageMode == PageMode.infinite ? refresher() : fetcher(_page));
    _clear();
    await _addAll(newItems.posts);
    _hasMore = newItems.posts.isNotEmpty;
    count.value = newItems.total;
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
      _hasMore = newItems.posts.isNotEmpty;
      if (_hasMore) {
        await _addAll(newItems.posts);
      }
      _loading = false;
      count.value = newItems.total;
      notifyListeners();
    });
  }

  // Jump to a specific page without knowing the total pages and allowing page skips
  Future<void> jumpToPage(int targetPage) async {
    if (_pageMode != PageMode.paginated || _loading || _refreshing) {
      return;
    }

    // make sure the target page is larger than 0
    _page = targetPage > 0 ? targetPage : _kFirstPage;
    _clear();
    _refreshing = true;
    notifyListeners();

    final newItems = await fetcher(_page);
    _hasMore = newItems.posts.isNotEmpty;
    if (_hasMore) {
      await _addAll(newItems.posts);
    }
    _refreshing = false;
    count.value = newItems.total;
    notifyListeners();
  }

  Future<void> goToPreviousPage() async {
    if (hasPreviousPage()) {
      await jumpToPage(_page - _kJumpStep);
    }
  }

  Future<void> goToNextPage() async {
    if (hasNextPage()) {
      await jumpToPage(_page + _kJumpStep);
    }
  }

  // Check if there is a previous page
  bool hasPreviousPage() {
    // Check if the current mode is paginated and there is a previous page
    return _pageMode == PageMode.paginated && _page > _kFirstPage;
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
    _filteredItems = data;
    notifyListeners();
  }

  void remove(List<int> postIds, int Function(T item) itemIdExtractor) {
    final data = [..._items]
      ..removeWhere((e) => postIds.contains(itemIdExtractor(e)));

    // remove keys
    _keys = data.map((e) => itemIdExtractor(e)).toSet();

    _items = data;
    _filteredItems = data;
    notifyListeners();
  }

  Future<void> _addAll(List<T> newItems) async {
    for (final item in newItems) {
      final key = item.id;
      if (!_keys.contains(key)) {
        _items.add(item);
        _keys.add(key);
      }
    }

    _total = _items.length;

    final bt = await _getBlacklistedTags();

    tagCounts.value = await _count(_items, bt);
    hasBlacklist.value = tagCounts.value.values.any((e) => e.isNotEmpty);

    // add unseen tags to activeFilters
    final unseenTags = tagCounts.value.keys
        .toSet()
        .difference(activeFilters.value.keys.toSet());
    activeFilters.value = {
      ...activeFilters.value,
      ...Map.fromIterable(unseenTags, value: (_) => true),
    };

    await _filter();
  }

  void _clear() {
    _items.clear();
    _filteredItems.clear();
    _keys.clear();
    tagCounts.value = {};
    hasBlacklist.value = false;
    activeFilters.value = {};
    notifyListeners();
  }
}

List<T> _filterInIsolate<T extends Post>(
  List<T> items,
  Map<String, Set<int>> tagCounts,
  Map<String, bool> activeFilters,
  Set<String> blacklistedUrls,
) {
  return items.where((e) {
    for (final entry in tagCounts.entries) {
      if (activeFilters[entry.key] == true && entry.value.contains(e.id)) {
        return false;
      }
    }

    if (blacklistedUrls.contains(e.originalImageUrl)) {
      return false;
    }
    return true;
  }).toList();
}

Future<Map<String, Set<int>>> _count<T extends Post>(
  Iterable<T> posts,
  Iterable<String> tags,
) =>
    Isolate.run(
      () => _countInIsolate(posts, tags),
    );

Future<List<T>> __filter<T extends Post>(
  List<T> items,
  Map<String, Set<int>> tagCounts,
  Map<String, bool> activeFilters,
  Set<String> blacklistedUrls,
) =>
    Isolate.run(
      () => _filterInIsolate(items, tagCounts, activeFilters, blacklistedUrls),
    );

Map<String, Set<int>> _countInIsolate<T extends Post>(
  Iterable<T> posts,
  Iterable<String> tags,
) {
  final Map<String, Set<int>> tagCounts = {};
  try {
    final preprocessed =
        tags.map((tag) => tag.split(' ').map(TagExpression.parse).toList());

    for (final item in posts) {
      for (final pattern in preprocessed) {
        if (item.containsTagPattern(pattern)) {
          final key = pattern.rawString;
          tagCounts.putIfAbsent(key, () => <int>{});
          tagCounts[key]!.add(item.id);
        }
      }
    }

    return tagCounts;
  } catch (e) {
    return {};
  }
}
