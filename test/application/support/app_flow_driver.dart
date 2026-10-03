import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:boorusama/core/bookmarks/src/data/bookmark_convert.dart';
import 'package:boorusama/core/bookmarks/src/pages/bookmark_details_page.dart';
import 'package:boorusama/core/bookmarks/src/pages/bookmark_page.dart';
import 'package:boorusama/core/configs/config/types.dart';
import 'package:boorusama/core/configs/create/src/pages/add_booru_page.dart';
import 'package:boorusama/core/configs/manage/src/widgets/booru_selector_item.dart';
import 'package:boorusama/core/download_manager/src/pages/download_manager_page.dart';
import 'package:boorusama/core/home/src/widgets/home_search_bar.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/search/search/src/widgets/search_app_bar.dart';
import 'package:boorusama/core/search/search/src/widgets/search_button.dart';
import 'package:boorusama/core/search/search/widgets.dart';

import 'app_flow_finders.dart';
import 'fake_booru_backend.dart';
import 'headless_app_harness.dart';

/// Common real-widget actions used by application-flow tests.
final class AppFlowDriver {
  const AppFlowDriver({
    required this.tester,
    required this.harness,
  });

  final WidgetTester tester;
  final HeadlessAppHarness harness;

  FakeBooruBackend get backend => harness.booruBackend;

  Iterable<FakeBooruPostRequest> get _postRequests =>
      backend.requests.whereType<FakeBooruPostRequest>();

  Future<void> scrollToLoadPage(int page) async {
    final before = _postRequests.where((r) => r.page == page).length;
    final scrollable = postGridScrollable();

    // Each fling outlasts the grid's 500 ms load-more debounce.
    for (var attempt = 0; attempt < 6; attempt++) {
      await tester.fling(scrollable, const Offset(0, -2400), 9000);
      await tester.pump(const Duration(milliseconds: 510));
      await tester.pump(const Duration(milliseconds: 30));
      if (_postRequests.where((r) => r.page == page).length > before) return;
    }

    throw TestFailure(
      'Scrolling did not start page $page. '
      'postCount=${postController(tester).allItems.length}, '
      'requests=${_postRequests.map((r) => '#${r.id}:${r.query}:${r.page}:${r.pending}').toList()}',
    );
  }

  Future<void> openPost(int id) async {
    final tile = postTile(id);
    await tester.scrollUntilVisible(
      tile,
      350,
      scrollable: postGridScrollable(),
    );
    await tester.ensureVisible(tile);
    await tester.pump();
    await tester.tap(tile);
    await tester.pump();
    await harness.pumpUntil(
      tester,
      () =>
          postDetailsScaffold().evaluate().isNotEmpty &&
          currentDetailPost(tester).id == id,
      description: 'details for post $id to become current',
    );
  }

  Future<void> openSearch() async {
    await tester.tap(find.byType(HomeSearchBar));
    await tester.pump();
    await harness.pumpUntilFound(tester, find.byType(SearchPageScaffold));
    await harness.settle(tester);
  }

  Future<void> submitSearch(
    String query, {
    bool waitForRequest = true,
  }) async {
    final field = find.descendant(
      of: find.byType(SearchAppBar),
      matching: find.byType(EditableText),
    );
    await tester.enterText(field, query);
    await tester.tap(field);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await harness.settle(tester);
    await tester.pump(const Duration(milliseconds: 300));
    final searchButton = find.byType(SearchButton2);
    await tester.ensureVisible(searchButton);
    await tester.tap(searchButton);
    await tester.pump();
    if (waitForRequest) {
      await harness.pumpUntil(
        tester,
        () => _postRequests.any((request) => request.query == query),
        description: 'search request for "$query" to start',
      );
    }
  }

  Future<void> clearSelectedSearchTags() async {
    final close = find.byIcon(Symbols.close);
    if (close.evaluate().isNotEmpty) {
      await tester.tap(close.last);
      await tester.pump();
    }
  }

  Future<void> openBookmarks() async {
    await _tapDrawerAction(appStrings(tester).sideMenu.your_bookmarks);
    await harness.pumpUntilFound(tester, find.byType(BookmarkPage));
  }

  Future<void> openBookmarkDetails({
    required int postId,
    required int booruId,
    required String sourceUrl,
  }) async {
    final tile = bookmarkTile(
      postId: postId,
      booruId: booruId,
      sourceUrl: sourceUrl,
    );
    await harness.pumpUntilFound(tester, tile);
    await tester.ensureVisible(tile);
    await tester.tap(tile);
    await harness.pumpUntilFound(tester, find.byType(BookmarkDetailsPage));
    await harness.pumpUntil(
      tester,
      () =>
          postDetailsScaffold().evaluate().isNotEmpty &&
          switch (currentDetailPost(tester)) {
            BookmarkPost(:final bookmark) =>
              bookmark.postId == postId &&
                  bookmark.booruId == booruId &&
                  bookmark.sourceUrl == sourceUrl,
            _ => false,
          },
      description: 'bookmark details for post $postId from booru $booruId',
    );
  }

  Future<void> openDownloadManager() async {
    await _tapDrawerAction(appStrings(tester).sideMenu.download_manager);
    await harness.pumpUntilFound(tester, find.byType(DownloadManagerPage));
  }

  Future<void> goBack() async {
    const routeTypes = [
      BookmarkDetailsPage,
      PostDetailsPageScaffold,
      BookmarkPage,
      DownloadManagerPage,
    ];
    final activeRouteType = routeTypes
        .where((type) => find.byType(type).evaluate().isNotEmpty)
        .firstOrNull;

    await tester.binding.handlePopRoute();
    switch (activeRouteType) {
      case final routeType?:
        await harness.pumpUntil(
          tester,
          () => find.byType(routeType).evaluate().isEmpty,
          description: '$routeType route to pop',
        );
      case null:
        await tester.pump(const Duration(milliseconds: 500));
    }
  }

  Future<void> selectProfile(BooruConfig config) async {
    final selector = await _reveal(
      _profileSelector(config.id),
      description: 'profile selector ${config.id}',
    );
    await tester.tap(selector);
    await tester.pump();
    await harness.pumpUntil(
      tester,
      () => _postRequests.any((request) => request.siteUrl == config.url),
      description: 'listing request for ${config.name}',
    );
  }

  /// Opens the edit/delete context menu of a profile in the selector.
  Future<void> openProfileMenu(BooruConfig config) async {
    final selector = await _reveal(
      _profileSelector(config.id),
      description: 'profile selector ${config.id}',
    );
    await tester.tap(selector, buttons: kSecondaryMouseButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> openAddProfile() async {
    final add = await _reveal(
      find.byIcon(Symbols.add),
      description: 'add profile button',
    );
    await tester.tap(add);
    await tester.pump();
    await harness.pumpUntilFound(tester, find.byType(AddBooruPageInternal));
    await tester.pump(const Duration(milliseconds: 500));
  }

  Future<void> _tapDrawerAction(String label) async {
    final action = await _reveal(
      find.text(label),
      description: 'drawer action "$label"',
    );
    await tester.tap(action);
    await tester.pump(const Duration(milliseconds: 500));
  }

  Finder _profileSelector(int configId) => find.byWidgetPredicate(
    (widget) => widget is BooruSelectorItem && widget.config.id == configId,
    description: 'profile selector item with ID $configId',
  );

  /// Returns the first on-screen match of [finder], opening the side menu
  /// first when the match lives in a closed drawer.
  Future<Finder> _reveal(Finder finder, {required String description}) async {
    if (_firstOnScreen(finder) case final match?) return match;

    final menuButton = find
        .descendant(
          of: find.byType(HomeSearchBar),
          matching: find.byIcon(Symbols.menu),
        )
        .hitTestable();
    if (menuButton.evaluate().isNotEmpty) {
      await tester.tap(menuButton.first);
    }

    await harness.pumpUntil(
      tester,
      () => _firstOnScreen(finder) != null,
      description: '$description to become visible',
    );
    return _firstOnScreen(finder)!;
  }

  Finder? _firstOnScreen(Finder finder) {
    final size = tester.view.physicalSize / tester.view.devicePixelRatio;
    final screen = Offset.zero & size;
    final count = finder.evaluate().length;
    for (var index = 0; index < count; index++) {
      final candidate = finder.at(index);
      final rect = tester.getRect(candidate);
      if (screen.contains(rect.topLeft) &&
          screen.contains(rect.bottomRight - const Offset(0.5, 0.5))) {
        return candidate;
      }
    }
    return null;
  }
}
