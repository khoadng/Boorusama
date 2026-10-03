// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:material_ui/material_ui.dart' show ListTile;
import 'package:sqlite3/sqlite3.dart';

// Project imports:
import 'package:boorusama/core/search/histories/src/data/repo_sqlite.dart';
import 'package:boorusama/core/search/histories/src/widgets/full_history_view.dart';
import 'package:boorusama/core/search/histories/src/widgets/search_history_section.dart';
import 'package:boorusama/core/search/search/src/widgets/search_app_bar.dart';
import 'package:boorusama/core/search/search/src/widgets/search_button.dart';
import 'package:boorusama/core/search/search/src/widgets/selected_tag_chip.dart';

import 'support/app_flow_driver.dart';
import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets(
    'searching again from history restores the tag, repeats the request, '
    'and keeps a single entry at the top',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);

      await app.search(['cat']);
      await app.search(['dog']);
      await app.openSearch();
      expect(app.history(), ['dog', 'cat']);

      await app.tapHistory('cat');
      expect(app.selectedTags(), ['cat']);

      await app.runSearch();
      expect(app.postQueries.where((q) => q == 'cat'), hasLength(2));

      await app.goHome();
      await app.openSearch();
      expect(app.history(), ['cat', 'dog']);
    },
  );

  testWidgets(
    'a multi-tag search is remembered as one entry that restores every tag '
    'in order',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);

      await app.search(['cat', 'blue_hair']);
      await app.openSearch();
      expect(app.history(), ['cat blue_hair']);

      await app.tapHistory('cat blue_hair');
      expect(app.selectedTags(), ['cat', 'blue_hair']);
    },
  );

  testWidgets(
    'a raw query is remembered as typed and comes back as one raw tag',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);

      await app.openSearch();
      await app.addRawQuery('cat -dog');
      await app.runSearch();
      await app.goHome();
      await app.openSearch();
      expect(app.history(), ['cat -dog']);

      await app.tapHistory('cat -dog');
      expect(app.selectedTags(), ['cat -dog']);
      expect(
        find.textContaining('RAW', findRichText: true),
        findsOneWidget,
      );
    },
  );

  testWidgets(
    'tapping history while tags are selected adds its tags to the selection',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);

      await app.search(['cat']);
      await app.openSearch();
      await app.addTag('dog');
      await app.tapHistory('cat');

      expect(app.selectedTags(), ['dog', 'cat']);
    },
  );

  testWidgets(
    'the search page lists the five newest searches while the full history '
    'keeps them all',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);
      const tags = ['a1', 'a2', 'a3', 'a4', 'a5', 'a6'];

      for (final tag in tags) {
        await app.search([tag]);
      }
      await app.openSearch();
      expect(app.history(), ['a6', 'a5', 'a4', 'a3', 'a2']);

      await app.openFullHistory();
      expect(app.fullHistory(), tags.reversed);
    },
  );

  testWidgets(
    'typing in the full history narrows the list and reopening it shows '
    'everything again',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);
      for (final tag in ['cat', 'dog', 'cat_ears']) {
        await app.search([tag]);
      }
      await app.openSearch();
      await app.openFullHistory();

      await app.filterFullHistory('cat');
      expect(app.fullHistory(), ['cat_ears', 'cat']);

      await app.closeFullHistory();
      await app.openFullHistory();
      expect(app.fullHistory(), ['cat_ears', 'dog', 'cat']);
    },
  );

  testWidgets(
    'tapping an entry in the full history returns to search with its tags',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);
      await app.search(['cat', 'blue_hair']);
      await app.openSearch();
      await app.openFullHistory();

      await app.tapFullHistory('cat blue_hair');

      expect(find.byType(FullHistoryView), findsNothing);
      expect(app.selectedTags(), ['cat', 'blue_hair']);
    },
  );

  testWidgets(
    'removing an entry from the full history removes it from the search page',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);
      for (final tag in ['cat', 'dog']) {
        await app.search([tag]);
      }
      await app.openSearch();
      await app.openFullHistory();

      await app.removeFromFullHistory('cat');
      expect(app.fullHistory(), ['dog']);

      await app.closeFullHistory();
      expect(app.history(), ['dog']);
    },
  );

  testWidgets(
    'clearing history asks first, and only confirming empties it',
    (tester) async {
      final app = await _SearchHistoryApp.mount(tester);
      await app.search(['cat']);
      await app.openSearch();
      await app.openFullHistory();
      final strings = appStrings(tester);

      await app.tapText(strings.search.history.clear);
      await app.tapText(strings.generic.action.cancel);
      expect(app.fullHistory(), ['cat']);

      await app.tapText(strings.search.history.clear);
      await app.tapText(strings.generic.action.ok);
      expect(app.fullHistory(), isEmpty);

      await app.closeFullHistory();
      expect(find.byType(SearchHistorySection), findsOneWidget);
      expect(
        find.text(strings.search.history.history.toUpperCase()),
        findsNothing,
      );
    },
  );

  testWidgets('search history is still there after restarting the app', (
    tester,
  ) async {
    final db = _openHistoryDb();
    final first = await _SearchHistoryApp.mount(tester, db: db);
    await first.search(['cat', 'blue_hair']);
    await first.harness.teardown(tester);

    final second = await _SearchHistoryApp.mount(tester, db: db);
    await second.openSearch();

    expect(second.history(), ['cat blue_hair']);
  });
}

Database _openHistoryDb() {
  final db = sqlite3.openInMemory();
  addTearDown(db.close);
  return db;
}

final _searchField = find.descendant(
  of: find.byType(SearchAppBar),
  matching: find.byType(EditableText),
);

/// Drives search history through the real SQLite store, which orders entries
/// by last use and merges repeats, unlike the in-memory fake.
final class _SearchHistoryApp {
  _SearchHistoryApp._(this.tester, this.harness)
    : driver = AppFlowDriver(tester: tester, harness: harness);

  static Future<_SearchHistoryApp> mount(
    WidgetTester tester, {
    Database? db,
  }) async {
    final backend = FakeBooruBackend();
    final harness = await HeadlessAppHarness.mount(
      tester,
      booruBackend: backend,
      runtime: backend.createRuntime(
        searchHistoryRepository: SearchHistoryRepositorySqlite(
          db: db ?? _openHistoryDb(),
        )..initialize(),
      ),
      viewportSize: kMobileViewport,
    );
    await harness.pumpUntilFound(tester, postTile(101));
    await harness.settle(tester);
    return _SearchHistoryApp._(tester, harness);
  }

  final WidgetTester tester;
  final HeadlessAppHarness harness;
  final AppFlowDriver driver;

  List<String> get postQueries => harness.booruBackend.requests
      .whereType<FakeBooruPostRequest>()
      .map((request) => request.query)
      .toList();

  /// Searches [tags] from the home screen and returns home.
  Future<void> search(List<String> tags) async {
    await openSearch();
    for (final tag in tags) {
      await addTag(tag);
    }
    await runSearch();
    await goHome();
  }

  Future<void> openSearch() async {
    await driver.openSearch();
    await harness.pumpUntilFound(tester, find.byType(SearchHistorySection));
  }

  Future<void> goHome() async {
    await tester.binding.handlePopRoute();
    await harness.pumpUntil(
      tester,
      () => find.byType(SearchAppBar).evaluate().isEmpty,
      description: 'search to close',
    );
    await harness.settle(tester);
  }

  Future<void> addTag(String tag) async {
    await tester.enterText(_searchField, tag);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await harness.settle(tester);
  }

  Future<void> addRawQuery(String query) async {
    await tapText(appStrings(tester).search.raw_query);
    await tester.enterText(find.byType(EditableText).last, query);
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await harness.settle(tester);
  }

  Future<void> runSearch() async {
    final query = selectedTags().join(' ');
    final before = postQueries.where((q) => q == query).length;
    // History is ordered by a millisecond timestamp, so keep searches from
    // landing on the same one.
    await tester.runAsync(() => Future<void>.delayed(_timestampGap));
    await harness.pumpUntilFound(tester, find.byType(SearchButton2));
    await tester.tap(find.byType(SearchButton2));
    await tester.pump();
    await harness.pumpUntil(
      tester,
      () => postQueries.where((q) => q == query).length > before,
      description: 'search request for "$query"',
    );
    await harness.settle(tester);
  }

  Future<void> tapText(String text) async {
    await tester.tap(find.text(text).last);
    await harness.settle(tester);
  }

  List<String> selectedTags() => tester
      .widgetList<SelectedTagChip>(find.byType(SelectedTagChip))
      .map((chip) => chip.tagSearchItem.originalTag)
      .toList();

  /// History entries on the search page, newest first.
  List<String> history() => _labels(find.byType(SearchHistorySection));

  Future<void> tapHistory(String label) async {
    final entry = _entry(find.byType(SearchHistorySection), label);
    await tester.ensureVisible(entry);
    await tester.tap(entry);
    await harness.settle(tester);
  }

  Future<void> openFullHistory() async {
    await tester.tap(find.byIcon(Symbols.manage_history));
    await harness.pumpUntilFound(tester, find.byType(FullHistoryView));
    await harness.settle(tester);
  }

  Future<void> closeFullHistory() async {
    await tester.binding.handlePopRoute();
    await harness.pumpUntil(
      tester,
      () => find.byType(FullHistoryView).evaluate().isEmpty,
      description: 'full history to close',
    );
    await harness.settle(tester);
  }

  List<String> fullHistory() => _labels(find.byType(FullHistoryView));

  Future<void> filterFullHistory(String text) async {
    await tester.enterText(
      find.descendant(
        of: find.byType(FullHistoryView),
        matching: find.byType(EditableText),
      ),
      text,
    );
    await harness.settle(tester);
  }

  Future<void> tapFullHistory(String label) async {
    await tester.tap(_entry(find.byType(FullHistoryView), label));
    await harness.settle(tester);
  }

  Future<void> removeFromFullHistory(String label) async {
    await tester.tap(
      find.descendant(
        of: _entry(find.byType(FullHistoryView), label),
        matching: find.byIcon(Symbols.close),
      ),
    );
    await harness.settle(tester);
  }

  Finder _entries(Finder list) =>
      find.descendant(of: list, matching: find.byType(ListTile));

  Finder _entry(Finder list, String label) {
    final entries = _entries(list);
    final count = entries.evaluate().length;
    return [
      for (var i = 0; i < count; i++) entries.at(i),
    ].singleWhere((entry) => _label(entry) == label);
  }

  List<String> _labels(Finder list) {
    final entries = _entries(list);
    final count = entries.evaluate().length;
    return [for (var i = 0; i < count; i++) _label(entries.at(i))];
  }

  /// The query an entry shows, with its tags joined by spaces.
  String _label(Finder entry) => tester
      .widgetList<Text>(
        find.descendant(
          of: find.descendant(
            of: entry,
            matching: find.byType(SearchHistoryQueryWidget),
          ),
          matching: find.byType(Text),
        ),
      )
      .map((text) => text.data)
      .join(' ');
}

const _timestampGap = Duration(milliseconds: 2);
