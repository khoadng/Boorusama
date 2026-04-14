// Package imports:
import 'dart:collection';

import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

// Project imports:
import '../../../../configs/config/types.dart';
import '../../../listing/providers.dart';
import '../../../listing/types.dart';
import '../../../post/types.dart';

class _PaginationState {
  /// A set tracking which indices (larger than indexOffset) have been accessed
  final Set<int> seenIndices = {};
  /// All indices below this offset were seen in a previous fetch cycle
  /// and must not be re-added to [seenIndices].
  var indexOffset = 0;

  /// Whether we have dispatched a fetchMore call that hasn't been
  /// reflected in a new reveal yet.
  var fetchPending = false;
  int get seenLength => seenIndices.length + indexOffset;
}

class DetailsPostsListing<T extends Post> extends ListBase<T> {
  /// instantiate a version of this which handles a handles a static list
  DetailsPostsListing.list({ required List<T> this.posts}):
        gridController = null,
        _getItem = ((index) => posts[index]),
        _pagination = _PaginationState(),
        dynlen = ValueNotifier<int>(posts.length);

  /// instatiate a version of this which handles a controller. This should be preferred where possible.
  DetailsPostsListing.controller({required PostGridController<dynamic> controller}):
        gridController = controller,
        posts = null,
        _getItem = ((index) => controller.items.elementAtOrNull(index)),
        _pagination = _PaginationState(),
        dynlen = ValueNotifier<int>(controller.items.length) {
    gridController!.itemsNotifier.addListener(_onItemsUpdated);
  }
   // shared-state constructor
  DetailsPostsListing._shared(DetailsPostsListing<dynamic> source, this._getItem):
        gridController = source.gridController,
        posts = source.posts,
        dynlen = source.dynlen,
        _pagination = source._pagination;

  final List<dynamic>? posts;
  final PostGridController<dynamic>? gridController;
  final ValueNotifier<int> dynlen;
  final T? Function(int index) _getItem;

  // --- pagination state ---
  final _PaginationState _pagination;

  DetailsPostsListing<T2> listingMap<T2 extends Post>(T2 Function(T) converter) {
    return DetailsPostsListing<T2>._shared(
      this,
      (index) => converter(this[index]),
    );
  }
  
  // ignore: avoid_setters_without_getters
  set initial(int intialIndex) => _pagination.indexOffset = intialIndex;

  @override
  int get length => dynlen.value;

  @override
  set length(int _) {
    // ListBase requires this to be implemented; mutations are not
    // supported for the controller case.
    throw UnsupportedError('DetailsPostsListing is read-only');
  }

  @override
  void operator []=(int index, T value) {
    throw UnsupportedError('DetailsPostsListing is read-only');
  }
  

  // hacky way to ensure paginated mode doesn't break
  late T _latestItem;
  @override
  T operator [](int index) {
    if (index == 1 || index == 2 || index == 3) {
      return _latestItem;
    }
    var item = _getItem(index);
    
    if (item == null){
      switch (gridController!.pageMode) {
        case PageMode.infinite:
          // this shouldn't happen, as fetch and reveal have already been triggered
          throw RangeError.index(index, this);
        case PageMode.paginated:
          item = _latestItem;
          _triggerFetch();
      }
    }
    _latestItem = item;
    return item;
  }

  @override
  List<T> toList({bool growable = false}) {
    throw UnsupportedError('DetailsPostsListing cannot be cast to list'); 
  }


  void markSeen(int index, {bool force = false}) {
    // Only track indices that belong to the *current* fetch cycle.
    if (gridController == null) return;
    if (index < _pagination.indexOffset) return;

    if (force) {
      // force mark all previous ones as seen
      _pagination.indexOffset = index;
      _pagination.seenIndices.clear();
    } else {
      _pagination.seenIndices.add(index);
    }

    // Trigger a background fetch when ≥ 3/4 of visible items accessed
    final visible = dynlen.value;
    switch (gridController!.pageMode) {
      case PageMode.infinite:
        if (visible > 0 &&
          _pagination.seenLength >= (visible * 3 / 4).ceil() &&
          !_pagination.fetchPending &&
          gridController!.hasMore &&
          !gridController!.loading &&
          !gridController!.refreshing) {
            _triggerFetch();
        }
        
        final currentItemCount = gridController!.items.length;
        final isLastVisible = _pagination.seenLength >= visible;

        if (isLastVisible && currentItemCount > visible) {
          _reveal(currentItemCount);
        }
      case PageMode.paginated:
        if (index == length-1) {
          _triggerFetch();
        }
    }
  }

  Future<void> _triggerFetch() async {
    if (!gridController!.hasMore) return;
    _pagination.fetchPending = true;
    switch (gridController!.pageMode) {
      case PageMode.infinite:
        await gridController!.fetchMore();
      case PageMode.paginated:
        await gridController!.goToNextPage();
    }
  }

  // ValueNotifier handler for PostGridController posts
  void _onItemsUpdated() {
    if (gridController == null) return;
    if (gridController!.items.isEmpty) return;
    _pagination.fetchPending = false;
    switch (gridController!.pageMode) {
      case PageMode.paginated:
        // when paginating, jump to next page immediately
        _reveal(gridController!.items.length);
    
      case PageMode.infinite:
        // infinite only reveals when all seen
    }
  }

  // reveal new items depending on criteria
  void _reveal(int newLength) {
    if (gridController!.items.isEmpty) return;
    switch (gridController!.pageMode) {
      case PageMode.paginated:
        // Completely new set of items → reset offset to zero.
        _pagination.indexOffset = 0;
      case PageMode.infinite:
        // Existing items are preserved; offset by previous visible count.
        _pagination.indexOffset = dynlen.value;
    }

    _pagination.seenIndices.clear();
    dynlen.value = newLength;
  }

  void dispose() {
    gridController?.itemsNotifier.removeListener(_onItemsUpdated);
    dynlen.dispose();
  }
}

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
