// Dart imports:
import 'dart:async';
import 'dart:isolate';

// Flutter imports:
import 'package:flutter/foundation.dart';

// Project imports:
import '../../../../../foundation/utils/collection_utils.dart';
import '../../../../errors/types.dart';
import '../../../../settings/settings.dart';
import '../../../filter/filter.dart';
import '../../../post/post.dart';
import 'post_duplicate_checker.dart';

const _kFirstPage = 1;
const _kJumpStep = 1;

typedef ItemFetcher<T extends Post> = Future<PostResult<T>> Function(int page);
typedef ItemRefresher<T extends Post> = Future<PostResult<T>> Function();

typedef PostGridFetcher<T extends Post> =
    PostsOrErrorCore<T> Function(
      int page,
    );

extension TagCountX on Map<String, Set<int>> {
  int get totalNonDuplicatesPostCount => values.expand((e) => e).toSet().length;
}

class PostGridController<T extends Post> extends ChangeNotifier {
  PostGridController({
    required this.fetcher,
    required this.blacklistedTagsFetcher,
    required this.mountedChecker,
    required PostDuplicateTracker<T> duplicateTracker,
    this.debounceDuration = const Duration(milliseconds: 500),
    PageMode pageMode = PageMode.infinite,
    this.blacklistedUrlsFetcher,
    this.forcedPageMode = false,
    this.initialPage,
  }) : _pageMode = pageMode,
       _duplicateTracker = duplicateTracker,
       _eventController = StreamController<PostControllerEvent>.broadcast() {
    // Initialize with initial page if provided
    if (initialPage != null) {
      _page = initialPage!;
      pageNotifier.value = initialPage!;
    }
  }

  final int? initialPage;

  final PostGridFetcher<T> fetcher;
  PageMode _pageMode;

  final Set<String> Function()? blacklistedUrlsFetcher;

  Set<String>? blacklistedTags;
  final Future<Set<String>> Function() blacklistedTagsFetcher;

  // Terrible hack to check if the widget is mounted, should have a better way to do this
  final bool Function() mountedChecker;

  List<T> _items = [];
  List<T> _filteredItems = [];

  final PostDuplicateTracker<T> _duplicateTracker;

  int _page = _kFirstPage;
  bool _hasMore = true;
  bool _loading = false;
  bool _refreshing = false;

  int _total = 0;

  Iterable<T> get items => _filteredItems;
  Iterable<T> get allItems => _items;

  bool get hasMore => _hasMore;
  bool get loading => _loading;
  bool get refreshing => _refreshing;
  int get page => pageNotifier.value;
  int get total => _total;

  final ValueNotifier<int?> count = ValueNotifier(null);
  final ValueNotifier<bool> refreshingNotifier = ValueNotifier(false);
  final ValueNotifier<List<T>> itemsNotifier = ValueNotifier(const []);
  final ValueNotifier<int> pageNotifier = ValueNotifier(_kFirstPage);

  Timer? _debounceTimer;
  final Duration debounceDuration;

  // Getter for _pageMode
  PageMode get pageMode => _pageMode;

  final activeFilters = ValueNotifier<Map<String, bool>>({});
  final tagCounts = ValueNotifier<Map<String, Set<int>>>({});
  final hasBlacklist = ValueNotifier(false);

  final errors = ValueNotifier<BooruError?>(null);

  final StreamController<PostControllerEvent> _eventController;
  Stream<PostControllerEvent> get events => _eventController.stream;

  final bool forcedPageMode;

  Future<PostResult<T>> _refreshPosts() => _fetchPosts(_kFirstPage);

  Future<PostResult<T>> _fetchPosts(int page) async {
    if (errors.value != null) {
      errors.value = null;
    }

    final result = await fetcher(page).run();

    return result.fold(
      (l) {
        if (mountedChecker()) {
          errors.value = l;
        }

        return <T>[].toResult();
      },
      (r) => r,
    );
  }

  Future<void> setBlacklistedTags(Set<String> tags) async {
    // check if the tags are the same
    if (blacklistedTags?.join(',') == tags.join(',')) return;

    final newTags = tags.toSet();
    blacklistedTags = newTags;

    tagCounts.value = await _count(_items, newTags);

    if (!mountedChecker()) return;

    hasBlacklist.value = tagCounts.value.values.any((e) => e.isNotEmpty);
    activeFilters.value = {
      ...activeFilters.value,
      ...Map.fromIterable(tags, value: (_) => true),
    };
    await _filter();

    if (!mountedChecker()) return;

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
    activeFilters.value = activeFilters.value.map(
      (key, value) => MapEntry(key, true),
    );

    await _filter();
    notifyListeners();
  }

  Future<void> disableAllTags() async {
    activeFilters.value = activeFilters.value.map(
      (key, value) => MapEntry(key, false),
    );

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

    _setFilteringItems(filteredItems);
  }

  // Set the page mode and reset the state
  void setPageMode(PageMode? newPageMode) {
    if (forcedPageMode) return; // Skip if page mode is forced
    if (newPageMode == null || _pageMode == newPageMode) return;

    _pageMode = newPageMode;

    _hasMore = true;
    _setRefreshing(false);
    _loading = false;
    if (newPageMode == PageMode.infinite) {
      _clear();
      _setPage(_kFirstPage);
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
    _setRefreshing(true);
    _eventController.add(const PostControllerRefreshStarted());
    _page = switch (_pageMode) {
      PageMode.infinite => _kFirstPage,
      PageMode.paginated =>
        (maintainPage || forcedPageMode) ? _page : _kFirstPage,
    };
    count.value = null;
    notifyListeners();

    final newItems = await (_pageMode == PageMode.infinite
        ? _refreshPosts()
        : _fetchPosts(_page));

    if (!mountedChecker()) return;

    _clear();
    await _addAll(newItems.posts);

    if (!mountedChecker()) return;

    _hasMore = newItems.posts.isNotEmpty;
    count.value = newItems.total;
    _setRefreshing(false);
    _eventController.add(const PostControllerRefreshCompleted());
    notifyListeners();
  }

  // Loads more items
  Future<void> fetchMore() async {
    if (_loading ||
        !_hasMore ||
        (_debounceTimer != null && _debounceTimer!.isActive)) {
      return;
    }

    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () async {
      _loading = true;
      if (_pageMode == PageMode.infinite) {
        _setPage(_page + 1);
      }
      notifyListeners();

      final newItems = await _fetchPosts(_page);
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
    _setPage(targetPage > 0 ? targetPage : _kFirstPage);
    _clear();
    _setRefreshing(true);
    notifyListeners();

    final newItems = await _fetchPosts(_page);
    _hasMore = newItems.posts.isNotEmpty;
    if (_hasMore) {
      await _addAll(newItems.posts);
    }
    _setRefreshing(false);
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
    final data = [..._items]..reorder(fromIndex, toIndex);
    onSuccess?.call();

    _items = data;
    _setFilteringItems(data);
    notifyListeners();
  }

  void remove(List<int> postIds, int Function(T item) itemIdExtractor) {
    final data = [..._items]
      ..removeWhere((e) => postIds.contains(itemIdExtractor(e)));

    _duplicateTracker.rebuildFrom(data);

    _items = data;
    _setFilteringItems(data);
    notifyListeners();
  }

  List<T> getPostsFromIds(List<int> ids) {
    final idSet = ids.toSet();

    if (idSet.isEmpty) return [];

    final result = <T>[];

    for (final item in _items) {
      if (idSet.contains(item.id)) {
        result.add(item);
      }

      if (result.length >= idSet.length) break;
    }

    return result;
  }

  Future<void> _addAll(List<T> newItems) async {
    for (final item in newItems) {
      if (!_duplicateTracker.isDuplicate(item)) {
        _items.add(item);
        _duplicateTracker.trackItem(item);
      }
    }

    _total = _items.length;

    final bt = await _getBlacklistedTags();

    tagCounts.value = await _count(_items, bt);
    hasBlacklist.value = tagCounts.value.values.any((e) => e.isNotEmpty);

    // add unseen tags to activeFilters
    final unseenTags = tagCounts.value.keys.toSet().difference(
      activeFilters.value.keys.toSet(),
    );
    activeFilters.value = {
      ...activeFilters.value,
      ...Map.fromIterable(unseenTags, value: (_) => true),
    };

    await _filter();
  }

  void _clear() {
    _items.clear();
    _filteredItems.clear();
    _setFilteringItems([]);
    _duplicateTracker.clear();
    tagCounts.value = {};
    hasBlacklist.value = false;
    activeFilters.value = {};
    notifyListeners();
  }

  void _setRefreshing(bool value) {
    _refreshing = value;
    refreshingNotifier.value = value;
  }

  void _setPage(int page) {
    _page = page;
    pageNotifier.value = page;
  }

  void _setFilteringItems(List<T> items) {
    _filteredItems = items;
    itemsNotifier.value = items;
  }

  @override
  void dispose() {
    _eventController.close();
    _debounceTimer?.cancel();

    itemsNotifier.dispose();
    count.dispose();
    refreshingNotifier.dispose();
    pageNotifier.dispose();
    activeFilters.dispose();
    tagCounts.dispose();
    hasBlacklist.dispose();
    errors.dispose();

    super.dispose();
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
) async {
  // If there are no tags, return an empty map to prevent isolate overhead
  if (tags.isEmpty) return {};

  return Isolate.run(
    () => _countInIsolate(posts, tags),
  );
}

Future<List<T>> __filter<T extends Post>(
  List<T> items,
  Map<String, Set<int>> tagCounts,
  Map<String, bool> activeFilters,
  Set<String> blacklistedUrls,
) async {
  // If there are no tags, active filters, or blacklisted urls, return the items as is to prevent isolate overhead
  if (tagCounts.isEmpty && blacklistedUrls.isEmpty) {
    return items.toList();
  }

  return Isolate.run(
    () => _filterInIsolate(items, tagCounts, activeFilters, blacklistedUrls),
  );
}

Map<String, Set<int>> _countInIsolate<T extends Post>(
  Iterable<T> posts,
  Iterable<String> tags,
) {
  final tagCounts = <String, Set<int>>{};
  try {
    final preprocessed = tags.map(
      (tag) => tag.split(' ').map(TagExpression.parse).toList(),
    );

    for (final item in posts) {
      final filterData = item.extractTagFilterData();
      for (final pattern in preprocessed) {
        if (checkIfTagsContainsTagExpression(filterData, pattern)) {
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

abstract class PostControllerEvent {
  const PostControllerEvent();
}

class PostControllerRefreshStarted extends PostControllerEvent {
  const PostControllerRefreshStarted();
}

class PostControllerRefreshCompleted extends PostControllerEvent {
  const PostControllerRefreshCompleted();
}
