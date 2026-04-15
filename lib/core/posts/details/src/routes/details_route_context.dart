// Package imports:
import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../listing/providers.dart';
import '../../../listing/types.dart';
import '../../../post/types.dart';

// ========== Internal Strategy Interface ==========
abstract class _ListingStrategy {
  ValueNotifier<int>? get length;
  dynamic getItemAt(int index);
  void markSeen(int index, {bool force});
  void dispose();
}


// ========== Public Wrapper Class ==========
class DetailsPostsListing<T extends Post> extends ListBase<T> {
  // Static list constructor
  DetailsPostsListing.list({required List<T> this.posts})
      : gridController = null,
        _convert = ((i) => i),
        _strategy = null,
        dynlen = ValueNotifier<int>(posts.length);

  // Controller constructor
  DetailsPostsListing.controller({required PostGridController<dynamic> controller})
      : gridController = controller,
        posts = (controller.pageMode == PageMode.paginated) ? controller.items.toList() : null, // FIXME: paginated mode unimplemented
        _convert = ((i) => (i)),
        dynlen = ValueNotifier<int>(controller.items.length){
          _strategy = (controller.pageMode == PageMode.paginated) ? null : _InfiniteStrategy(controller, dynlen);
        }

  // Shared-state constructor (for listingMap)
  DetailsPostsListing._shared(DetailsPostsListing<dynamic> source, this._convert)
      : gridController = source.gridController,
        posts = source.posts,
        dynlen = source.dynlen,
        _strategy = source._strategy;

  final List<dynamic>? posts;
  final PostGridController<dynamic>? gridController;
  final ValueNotifier<int> dynlen;
  final T Function(dynamic) _convert;
  _ListingStrategy? _strategy;


  DetailsPostsListing<T2> listingMap<T2 extends Post>(T2 Function(T) converter) {
    return DetailsPostsListing<T2>._shared(
      this,
      (i) => converter(i)
      // (item) {
      //   if (item == null) return null;
      //   return converter(item);
      // },
    );
  }

  set initial(int initialIndex) {
    final strat = _strategy;
    if (strat is _InfiniteStrategy) {
      strat.indexOffset = initialIndex;
    }
  }

  @override
  int get length {
    if (posts != null) return posts!.length;
    return dynlen.value;
  }

  @override
  set length(int _) => throw UnsupportedError('DetailsPostsListing is read-only');

  @override
  void operator []=(int index, T value) => throw UnsupportedError('DetailsPostsListing is read-only');

  @override
  T operator [](int index) {
    // Static list case
    if (posts != null) {
      return _convert(posts![index]);
    }

    // Controller case with strategy
    return _convert(_strategy!.getItemAt(index));

  }

  void markSeen(int index, {bool force = false}) {
    if (posts != null) return;
    _strategy?.markSeen(index, force: force);
  }

  void dispose() {
    _strategy?.dispose();
    dynlen.dispose();
  }
}

// ========== Infinite Strategy (exact replica of original logic) ==========
class _InfiniteStrategy implements _ListingStrategy {
  _InfiniteStrategy(this.gridController, this.length);

  final PostGridController<dynamic> gridController;
  Set<int> seenIndices = {};
  var indexOffset = 0;
  var fetchPending = false;
  int get seenLength => seenIndices.length + indexOffset;
  @override
  final ValueNotifier<int> length;


  @override
  dynamic getItemAt(int index) {
    // The infinite strategy relies on the controller's items directly.
    // No additional caching; just fetch from controller.
    return gridController.items.elementAtOrNull(index);
  }

  @override
  void markSeen(int index, {bool force = false}) {
    if (index < indexOffset) return;

    if (force) {
      indexOffset = index;
      seenIndices.clear();
    } else {
      seenIndices.add(index);
    }

    final visible = length.value;
    if (visible > 0 &&
        seenLength >= (visible * 3 / 4).ceil() &&
        !fetchPending &&
        gridController.hasMore &&
        !gridController.loading &&
        !gridController.refreshing) {
      _triggerFetch();
    }

    final isLastVisible = seenLength >= visible - 1;

    final currentItemCount = gridController.items.length;
    if (isLastVisible && currentItemCount > visible) {
      _reveal(currentItemCount);
    }
  }

  Future<void> _triggerFetch() async {
    if (!gridController.hasMore) return;
    fetchPending = true;
    await gridController.fetchMore();
  }

  void _reveal(int newLength) {
    indexOffset = length.value;
    fetchPending = false;
    seenIndices.clear();
    length.value = newLength;
  }


  @override
  void dispose() {
  }
  

}

// // ========== Paginated Strategy (sliding‑window cache) ==========
// class _PaginatedStrategy implements _ListingStrategy {
//   _PaginatedStrategy(this.gridController) {
//     gridController.itemsNotifier.addListener(onItemsUpdated);
//     gridController.pageNotifier.addListener(_onPageChanged);

//     _currentControllerPage = gridController.page;
//     if (gridController.items.isNotEmpty) {
//       _pageCache[_currentControllerPage] = List.from(gridController.items);
//     }
//   }

//   final PostGridController<dynamic> gridController;
//   void Function(int) _updateLength = (l) => ();

//   final Map<int, List<dynamic>> _pageCache = {};
//   var _baseOffset = 0;
//   var _currentControllerPage = 1;
//   var _isLoadingPage = false;


//   void _onPageChanged() {
//     _currentControllerPage = gridController.page;
//   }

//   List<int> get _sortedPages => _pageCache.keys.toList()..sort();
//   int get _cachedLength => _sortedPages.fold(0, (sum, p) => sum + _pageCache[p]!.length);

//   @override
//   int get length => _baseOffset + _cachedLength;


//   @override
//   dynamic? getItemAt(int index) {
//     var runningOffset = _baseOffset;
//     for (final page in _sortedPages) {
//       final pageItems = _pageCache[page]!;
//       if (index >= runningOffset && index < runningOffset + pageItems.length) {
//         final localIndex = index - runningOffset;
//         _prefetchIfNeeded(page, localIndex, pageItems.length);
//         return pageItems[localIndex];
//       }
//       runningOffset += pageItems.length;
//     }

//     // Not in cache – determine direction
//     int targetPage;
//     if (_pageCache.isEmpty) {
//       targetPage = 1;
//     } else if (index < _baseOffset) {
//       targetPage = _sortedPages.first - 1;   // need older page
//     } else {
//       targetPage = _sortedPages.last + 1;    // need newer page
//     }

//     Future.microtask(() => _loadPageIfNeeded(targetPage));
//     return null;
//   }

//   void _prefetchIfNeeded(int page, int localIndex, int pageLength) {
//     // Prefetch next page when near the end of current page
//     if (localIndex >= pageLength - 2) {
//       _loadPageIfNeeded(page + 1);
//     }
//     // Prefetch previous page when near the beginning (and not on first page)
//     if (localIndex <= 1 && page > 1) {
//       _loadPageIfNeeded(page - 1);
//     }
//   }

//   Future<void> _loadPageIfNeeded(int page) async {
//     if (_isLoadingPage) return;
//     if (_pageCache.containsKey(page)) return;
//     if (page < 1) return;

//     _isLoadingPage = true;
//     unawaited(Future.microtask(() async {
//       try {
//         // Snapshot current page before jumping away
//         final currentPage = _currentControllerPage;
//         if (gridController.items.isNotEmpty && !_pageCache.containsKey(currentPage)) {
//           _addPageToCache(currentPage, List.from(gridController.items));
//         }

//         await gridController.jumpToPage(page);

//         // Cache the newly loaded page
//         if (gridController.items.isNotEmpty) {
//           _addPageToCache(page, List.from(gridController.items));
//         }

//         _evictDistantPages(page);
//         _updateLength(length);
//       } finally {
//         _isLoadingPage = false;
//       }
//     }));
//   }

//   void _addPageToCache(int page, List<dynamic> items) {
//     final wasEmpty = _pageCache.isEmpty;
//     final oldOldest = wasEmpty ? null : _sortedPages.first;

//     _pageCache[page] = items;

//     if (!wasEmpty && page < oldOldest!) {
//       // New page is older than previous oldest → it is now cached,
//       // so its items are no longer "evicted". Subtract from baseOffset.
//       _baseOffset -= items.length;
//     }
//   }

//   void _evictDistantPages(int centerPage) {
//     final pagesToRemove = _pageCache.keys.where((p) => (p - centerPage).abs() > 1).toList();
//     if (pagesToRemove.isEmpty) return;

//     pagesToRemove.sort();
//     for (final page in pagesToRemove) {
//       if (page == _sortedPages.first) {
//         // This is the oldest page in cache; it's being evicted.
//         // Add its length to baseOffset.
//         _baseOffset += _pageCache[page]!.length;
//       }
//       _pageCache.remove(page);
//     }
//   }

//   @override
//   void markSeen(int index, {bool force = false}) {
//     getItemAt(index); // just ensure the page is loaded
//   }


//   @override
//   void dispose() {
//     gridController.itemsNotifier.removeListener(onItemsUpdated);
//     gridController.pageNotifier.removeListener(_onPageChanged);
//     _pageCache.clear();
//   }
// }


class DetailsRouteContext<T extends Post> extends Equatable {
  DetailsRouteContext({
    required this.initialIndex,
    required this.posts,
    required this.scrollController,
    required this.isDesktop,
    required this.hero,
    required this.initialThumbnailUrl,
    required this.configSearch,
    this.dislclaimer,
  }){
    posts.initial = initialIndex;
  }

  DetailsRouteContext<T> copyWith({
    int? initialIndex,
    AutoScrollController? scrollController,
    bool? isDesktop,
  }) {
    return DetailsRouteContext<T>(
      initialIndex: initialIndex ?? this.initialIndex,
      posts: posts,
      scrollController: scrollController ?? this.scrollController,
      isDesktop: isDesktop ?? this.isDesktop,
      hero: hero,
      initialThumbnailUrl: initialThumbnailUrl,
      dislclaimer: dislclaimer,
      configSearch: configSearch,
    );
  }

  final int initialIndex;
  final DetailsPostsListing<T> posts;
  final AutoScrollController? scrollController;
  final bool isDesktop;
  final bool hero;
  final String? initialThumbnailUrl;
  final String? dislclaimer;
  final BooruConfigSearch? configSearch;

  @override
  List<Object?> get props => [
    initialIndex,
    posts,
    scrollController,
    isDesktop,
    hero,
    initialThumbnailUrl,
    dislclaimer,
  ];
}
