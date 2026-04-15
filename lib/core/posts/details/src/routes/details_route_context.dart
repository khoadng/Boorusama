// Package imports:
import 'dart:async';
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../details_pageview/src/post_details_page_view_controller.dart';
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
        posts =  null,
        _convert = ((i) => i),
        dynlen = ValueNotifier<int>(controller.items.length){
          _strategy = (controller.pageMode == PageMode.paginated) ? _PaginatedStrategy(controller, dynlen) : _InfiniteStrategy(controller, dynlen);
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
    );
  }

  void setPostDetailsPageViewController(PostDetailsPageViewController postDetailsPage) {
    final strat = _strategy;
    
    if (strat is _InfiniteStrategy) {
      strat.indexOffset = postDetailsPage.initialPage;
    } else if (strat is _PaginatedStrategy) {
      strat.postDetailsPage = postDetailsPage;
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

    final currentlyLoaded = length.value;
    if (currentlyLoaded > 0 &&
        seenLength >= (currentlyLoaded * 3 / 4).ceil() &&
        !fetchPending &&
        gridController.hasMore &&
        !gridController.loading &&
        !gridController.refreshing) {
      _triggerFetch();
    }

    final isLastVisible = seenLength >= currentlyLoaded - 1;

    final currentItemCount = gridController.items.length;
    if (isLastVisible && currentItemCount > currentlyLoaded) {
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

// ========== Paginated Strategy Implementation ==========
class _PaginatedStrategy implements _ListingStrategy {
  _PaginatedStrategy(
    this._controller,
    this._dynlen,
  ):
  _firstPage = _controller.pageNotifier.value,
  _lastPage = _controller.pageNotifier.value,
  _forwards = _controller.items.toList()
   {
    _updateLength();
    // Immediately start loading the previous page if it exists.
    if (_controller.hasPreviousPage()) {
      _loadPreviousPage();
    }
  }

  final PostGridController<dynamic> _controller;
  final ValueNotifier<int> _dynlen;
  PostDetailsPageViewController? postDetailsPage;

  // Own storage: backwards (reversed order) and forwards (normal order)
  final List<dynamic> _forwards; // initialize in constructor
  final List<dynamic> _backwards = []; // stored as [..., page_{N-1}_last, ..., page_{N-1}_0]
  int _firstPage; // smallest page number currently in _backwards
  int _lastPage;  // largest page number currently in _forwards

  // Seen indices management
  final Set<int> _seenIndices = {};
  int? _lastMarkedIndex;

  // Loading guard
  var _loading = false;

  @override
  ValueNotifier<int>? get length => _dynlen;

  @override
  dynamic getItemAt(int index) {
    final backLen = _backwards.length;
    if (index < backLen) {
      // Combined list: backwards part is reversed.
      return _backwards[backLen - 1 - index];
    } else {
      return _forwards[index - backLen];
    }
  }

  @override
  void markSeen(int index, {bool force = false}) {
    // force is ignored – we simply let the set grow as requested.
    if (_seenIndices.add(index)) {
      _lastMarkedIndex = index;
    }
    _maybeLoadMorePages();
  }

  void _maybeLoadMorePages() {
    final totalLen = _dynlen.value;
    final seenCount = _seenIndices.length;

    // Threshold: 3/4 of the currently loaded items have been marked.
    final thresholdReached = seenCount >= (totalLen * 3 / 4).ceil();

    if (thresholdReached && _lastMarkedIndex != null) {
      final center = totalLen / 2;
      if (_lastMarkedIndex! > center) {
        // User has moved to the second half → load next page.
        if (_controller.hasNextPage() && !_loading) {
          _loadNextPage();
        }
      } else {
        // User is in the first half → load previous page.
        if (_controller.hasPreviousPage() && !_loading) {
          _loadPreviousPage();
        }
      }
    } else {
      // Immediate edge triggers.
      if (_seenIndices.contains(0) &&
          _controller.hasPreviousPage() &&
          !_loading) {
        _loadPreviousPage();
      }
      if (_seenIndices.contains(totalLen - 1) &&
          _controller.hasNextPage() &&
          !_loading) {
        _loadNextPage();
      }
    }
  }

  Future<void> _loadPreviousPage() async {
    if (_loading) return;
    _loading = true;

    final targetPage = _firstPage - 1;
    if (!_controller.hasPreviousPage() || targetPage < 1) {
      _loading = false;
      return;
    }

    try {
      final newPageItems = await _fetchPage(targetPage);
      if (newPageItems.isEmpty) {
        // No items on that page – treat as end of data.
        _loading = false;
        return;
      }

      final addedCount = newPageItems.length;

      // Insert new page at the beginning of the combined list.
      // Backwards list stores pages in reverse order, so we append the new
      // page’s items in reverse order.
      _backwards.addAll(newPageItems.reversed);
      _firstPage = targetPage;

      // Update length.
      _updateLength();

      // Shift existing seen indices because new items were inserted before them.
      final updatedIndices = <int>{};
      for (final idx in _seenIndices) {
        updatedIndices.add(idx + addedCount);
      }
      _seenIndices.clear();
      _seenIndices.addAll(updatedIndices);
      if (_lastMarkedIndex != null) {
        _lastMarkedIndex = _lastMarkedIndex! + addedCount;
      }
      postDetailsPage!.jumpToPage(postDetailsPage!.currentPage.value + addedCount);
    } finally {
      _loading = false;
    }
  }

  Future<void> _loadNextPage() async {
    if (_loading) return;
    _loading = true;

    final targetPage = _lastPage + 1;
    if (!_controller.hasNextPage()) {
      _loading = false;
      return;
    }

    try {
      final newPageItems = await _fetchPage(targetPage);
      if (newPageItems.isEmpty) {
        _loading = false;
        return;
      }

      // Append to forwards (normal order).
      _forwards.addAll(newPageItems);
      _lastPage = targetPage;
      _updateLength();

      // No index shift needed when appending at the end.
    } finally {
      _loading = false;
    }
  }

  Future<List<dynamic>> _fetchPage(int page) async {
    // Use a completer to wait for the controller’s items to be updated.
    await _controller.jumpToPage(page);
    return _controller.items.toList();
  }

  void _updateLength() {
      _dynlen.value = _backwards.length + _forwards.length;
  }

  @override
  void dispose() {
  }
}

class DetailsRouteContext<T extends Post> extends Equatable {
  const DetailsRouteContext({
    required this.initialIndex,
    required this.posts,
    required this.scrollController,
    required this.isDesktop,
    required this.hero,
    required this.initialThumbnailUrl,
    required this.configSearch,
    this.dislclaimer,
  });

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
