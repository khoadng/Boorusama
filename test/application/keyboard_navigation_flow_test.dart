import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:kurumi/kurumi.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:boorusama/core/changelogs/dialog.dart';
import 'package:boorusama/core/changelogs/providers.dart';
import 'package:boorusama/core/changelogs/types.dart';
import 'package:boorusama/core/configs/create/src/widgets/create_config_button.dart';
import 'package:boorusama/core/home/src/pages/entry_page.dart';
import 'package:boorusama/core/search/search/src/views/search_landing_view.dart';
import 'package:boorusama/core/search/search/src/widgets/desktop_search_bar.dart';
import 'package:boorusama/core/settings/src/pages/settings_page.dart';

import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';
import 'support/keyboard_flow_driver.dart';

void main() {
  testWidgets('remote can open a post and return home without touching', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openPostWithRemote(keys);

    await keys.navigateTo(_detailsBackButton());
    await keys.select();
    await keys.harness.pumpUntil(
      tester,
      () => postDetailsScaffold().evaluate().isEmpty,
      description: 'details page to close',
    );
    expect(find.byType(EntryPage), findsOneWidget);
  });

  testWidgets('remote back button closes the post details page', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openPostWithRemote(keys);

    await keys.back();
    await keys.harness.pumpUntil(
      tester,
      () => postDetailsScaffold().evaluate().isEmpty,
      description: 'details page to close',
    );
  });

  testWidgets('arrows change posts only while no control is focused', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester, posts: testPostRange(101, 103));
    await _openPostWithRemote(keys);

    await keys.navigateTo(_detailsBackButton());
    await keys.arrow(TraversalDirection.right);
    expect(currentDetailPost(tester).id, 101);
    expect(keys.isFocusWithin(_detailsBackButton()), isFalse);

    await keys.back();
    await _openPostWithRemote(keys);
    await keys.arrow(TraversalDirection.right);
    await keys.harness.pumpUntil(
      tester,
      () => currentDetailPost(tester).id == 102,
      description: 'right arrow to show the next post',
    );
  });

  final dismissals = [
    (name: 'select', dismiss: (KeyboardFlowDriver keys) => keys.select()),
    (name: 'back', dismiss: (KeyboardFlowDriver keys) => keys.back()),
  ];
  for (final c in dismissals) {
    testWidgets('remote ${c.name} button closes the changelog dialog', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester, showChangelog: true);
      await keys.harness.pumpUntilFound(tester, find.byType(ChangelogDialog));

      await c.dismiss(keys);

      await keys.harness.pumpUntil(
        tester,
        () => find.byType(ChangelogDialog).evaluate().isEmpty,
        description: 'changelog dialog to close',
      );
    });
  }

  testWidgets('arrowing onto the search bar does not start typing', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);

    await keys.navigateTo(find.byType(DesktopSearchbar));
    expect(tester.testTextInput.isVisible, isFalse);

    await keys.navigateTo(postTile(101));
  });

  testWidgets('remote moves from typing a search into suggestions and back', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await keys.navigateTo(find.byType(DesktopSearchbar));
    await keys.select();
    expect(tester.testTextInput.isVisible, isTrue);

    await keys.arrow(TraversalDirection.down);
    expect(keys.isFocusWithin(_searchSuggestions), isTrue);

    await keys.arrow(TraversalDirection.up);
    expect(keys.isFocusWithin(_searchField), isTrue);
    expect(tester.testTextInput.isVisible, isTrue);
  });

  testWidgets('remote back closes search suggestions and stays home', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openSearchSuggestions(keys);

    await keys.back();

    expect(_searchSuggestions.evaluate(), isEmpty);
    expect(keys.isFocusWithin(find.byType(DesktopSearchbar)), isTrue);
    expect(find.byType(EntryPage), findsOneWidget);
  });

  testWidgets('remote can reach every search suggestion', (tester) async {
    final keys = await _mountOnTv(tester);
    await _openSearchSuggestions(keys);

    expect(
      await keys.unreachableIn(
        _searchSuggestions,
        reopen: () => _openSearchSuggestions(keys),
      ),
      isEmpty,
    );
  });

  testWidgets('search suggestions show clearly where focus is', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openSearchSuggestions(keys);

    expect(await keys.faintFocus(within: _searchSuggestions), isEmpty);
  });

  testWidgets('arrows skip controls scrolled out of view under a header', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);
    await _openRoute(keys, _editProfilePath);
    await keys.navigateTo(find.byType(CreateOrUpdateBooruConfigButton));

    // Scrolled by mouse or touch, so tiles sit hidden under the header.
    final list = find.byWidgetPredicate(
      (widget) =>
          widget is Scrollable && widget.axisDirection == AxisDirection.down,
    );
    tester.state<ScrollableState>(list.last).position.jumpTo(300);
    await keys.harness.settle(tester);

    await keys.arrow(TraversalDirection.left);

    expect(keys.isFocusWithin(find.byTooltip('Back')), isTrue);
  });

  testWidgets('remote can open settings from the sidebar and close it', (
    tester,
  ) async {
    final keys = await _mountOnTv(tester);

    await keys.navigateTo(_sidebarTile(Symbols.settings));
    await keys.select();
    await keys.harness.pumpUntilFound(tester, find.byType(SettingsPage));

    await keys.back();
    await keys.harness.pumpUntil(
      tester,
      () => find.byType(SettingsPage).evaluate().isEmpty,
      description: 'settings to close',
    );
  });

  final screens = [
    (
      name: 'home',
      open: (KeyboardFlowDriver _) => Future<void>.value(),
    ),
    (name: 'post details', open: _openPostWithRemote),
    for (final path in [..._screenPaths, _editProfilePath])
      (name: path, open: (KeyboardFlowDriver keys) => _openRoute(keys, path)),
  ];
  for (final c in screens) {
    testWidgets('the ${c.name} screen has no remote dead ends', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester);
      await c.open(keys);

      expect(await keys.focusProblems(), isEmpty);
    });

    testWidgets('the ${c.name} screen shows clearly where focus is', (
      tester,
    ) async {
      final keys = await _mountOnTv(tester);
      await c.open(keys);

      expect(await keys.faintFocus(), isEmpty);
    });
  }
}

/// Screens a remote user reaches from the home sidebar or settings.
const _screenPaths = [
  '/search',
  '/settings?initial=appearance',
  '/settings?initial=language',
  '/settings?initial=download',
  '/settings?initial=data_and_storage',
  '/settings?initial=backup_and_restore',
  '/settings?initial=search',
  '/settings?initial=accessibility',
  '/settings?initial=viewer',
  '/settings?initial=privacy',
  '/bookmarks',
  '/favorites',
  '/artists?name=cat',
  '/download_manager',
  '/bulk_downloads',
  '/bulk_downloads/saved',
  '/bulk_downloads/completed',
  '/favorite_tags',
  '/global_blacklisted_tags',
  '/boorus/add',
  '/changelog',
  '/premium',
  '/donate',
];

final _editProfilePath = '/boorus/${FakeBooruBackend().config.id}/update';

final _searchSuggestions = find.byType(SearchLandingView);

final _searchField = find.descendant(
  of: find.byType(DesktopSearchbar),
  matching: find.byType(EditableText),
);

/// Starts typing in the search bar and moves down into its suggestions.
Future<void> _openSearchSuggestions(KeyboardFlowDriver keys) async {
  final tester = keys.tester;
  tester.state<EditableTextState>(_searchField).widget.focusNode.requestFocus();
  await keys.harness.settle(tester);
  await keys.arrow(TraversalDirection.down);
  expect(keys.isFocusWithin(_searchSuggestions), isTrue);
}

Future<void> _openRoute(KeyboardFlowDriver keys, String path) async {
  final tester = keys.tester;
  unawaited(
    GoRouter.of(tester.element(find.byType(Navigator).first)).push(path),
  );
  await keys.harness.settle(tester);
  await tester.pump(const Duration(milliseconds: 500));
  await keys.harness.settle(tester);
}

Future<void> _openPostWithRemote(KeyboardFlowDriver keys) async {
  await keys.navigateTo(postTile(101));
  await keys.select();
  await keys.harness.pumpUntilFound(keys.tester, postDetailsScaffold());
  await keys.harness.settle(keys.tester);
}

Future<KeyboardFlowDriver> _mountOnTv(
  WidgetTester tester, {
  bool showChangelog = false,
  List<TestPost>? posts,
}) async {
  final backend = FakeBooruBackend()
    ..enqueuePosts(page: 1, posts: posts ?? testPostRange(101, 101));
  final harness = await HeadlessAppHarness.mount(
    tester,
    booruBackend: backend,
    viewportSize: kTvViewport,
    additionalOverrides: [
      changelogRepositoryProvider.overrideWith(
        (ref) => _FakeChangelogRepository(showChangelog: showChangelog),
      ),
    ],
  );
  await harness.pumpUntilFound(tester, postTile(101));
  await harness.settle(tester);

  return KeyboardFlowDriver(tester: tester, harness: harness);
}

Finder _sidebarTile(IconData icon) => find.ancestor(
  of: find.byIcon(icon),
  matching: find.byType(KurumiNavigationTile),
);

Finder _detailsBackButton() => find.ancestor(
  of: find.byIcon(Symbols.arrow_back_ios),
  matching: find.byType(KurumiCircularIconButton),
);

final class _FakeChangelogRepository implements ChangelogRepository {
  _FakeChangelogRepository({required this.showChangelog});

  bool showChangelog;

  @override
  Future<ChangelogData> loadLatestChangelog() async => ChangelogData(
    previousVersion: null,
    version: ReleaseVersion.fromText('9.0.0'),
    content: '- Remote navigation fixes',
  );

  @override
  Future<String> loadFullChangelog() async => '';

  @override
  Future<void> markChangelogAsSeen(ReleaseVersion version) async =>
      showChangelog = false;

  @override
  Future<bool> shouldShowChangelog(ReleaseVersion version) async =>
      showChangelog;
}
