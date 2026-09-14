import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/kurumi.dart';

import 'package:boorusama/core/home/src/widgets/home_search_bar.dart';
import 'package:boorusama/core/search/search/src/widgets/search_button.dart';

import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';
import '../support/fakes/memory_repositories.dart';

void main() {
  testWidgets('persists a search in history through the real search flow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 800);
    tester.view.devicePixelRatio = 1;

    final backend = FakeBooruBackend();
    final historyRepository = MemorySearchHistoryRepository();
    final harness = HeadlessAppHarness(
      booruBackend: backend,
      runtime: backend.createRuntime(
        searchHistoryRepository: historyRepository,
      ),
    );
    addTearDown(() => harness.teardown(tester));

    await harness.pump(tester);
    await harness.settle(tester);

    await tester.tap(find.byType(HomeSearchBar));
    await tester.pump();
    await harness.settle(tester);

    final searchField = find.byType(KurumiTextField);
    expect(searchField, findsOneWidget);
    await tester.enterText(searchField, 'cat');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pump();
    await harness.pumpUntilFound(tester, find.byType(SearchButton2));
    tester.widget<SearchButton2>(find.byType(SearchButton2)).onTap!.call();
    await tester.pump();

    await harness.pumpUntil(
      tester,
      () => backend.requests.any(
        (request) =>
            request is FakeBooruPostRequest && request.tags.contains('cat'),
      ),
    );
    await harness.pumpUntil(
      tester,
      () => historyRepository.historiesForTest.any(
        (history) => history.query.contains('cat'),
      ),
    );

    await tester.binding.handlePopRoute();
    await tester.pump();
    await harness.settle(tester);
    await tester.tap(find.byType(HomeSearchBar));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    await harness.pumpUntilFound(tester, find.text('cat'));

    expect(find.text('cat'), findsWidgets);
  });
}
