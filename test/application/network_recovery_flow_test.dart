import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boorusama/core/configs/manage/providers.dart';
import 'package:boorusama/core/errors/error.dart';
import 'package:boorusama/core/home/types.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';
import 'package:boorusama/core/search/search/src/widgets/selected_tag_chip.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/core/widgets/error_box.dart';

import 'support/app_flow_driver.dart';
import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  final retriableErrors = <(BooruError, Finder Function(BooruError))>[
    (
      AppError(
        type: AppErrorType.cannotReachServer,
        message: 'connection unavailable',
      ),
      (_) => find.byType(ErrorBox),
    ),
    (
      ServerError(httpStatusCode: 500, message: 'server unavailable'),
      (error) => find.text('${(error as ServerError).httpStatusCode}'),
    ),
  ];

  for (final (error, errorPresentation) in retriableErrors) {
    testWidgets('renders retry and recovers from $error', (tester) async {
      final backend = FakeBooruBackend(strictPostScripts: true);
      final gate = backend.enqueuePostGate(
        siteUrl: backend.config.url,
        query: '',
        page: 1,
      );
      backend.enqueuePosts(page: 1, posts: [backend.posts.first]);
      final harness = await _mount(tester, backend);

      await harness.pumpUntil(
        tester,
        () => _requests(backend).any((request) => request.page == 1),
        description: 'initial page request to start and remain gated',
      );
      expect(_requests(backend).first.pending, isTrue);

      gate.completeFailure(error);
      await harness.pumpUntilFound(tester, errorPresentation(error));
      final controller = postController(tester);
      expect(controller.errors.value, error);

      await tester.tap(find.text(appStrings(tester).generic.action.retry));
      await harness.pumpUntil(
        tester,
        () =>
            _requests(backend).where((r) => r.page == 1).length == 2 &&
            controller.allItems.length == 1 &&
            errorPresentation(error).evaluate().isEmpty,
        description: 'visible retry to reload page one',
      );
      expect(controller.errors.value, isNull);
      expect(loadedPostIds(tester), [101]);
      expect(find.byType(SliverPostGridImageGridItem), findsOneWidget);

      await AppFlowDriver(tester: tester, harness: harness).openPost(101);
      expect(currentDetailPost(tester).id, 101);
    });
  }

  testWidgets('page two failure retries through full listing refresh', (
    tester,
  ) async {
    final backend = FakeBooruBackend(strictPostScripts: true)
      ..enqueuePosts(page: 1, posts: testPostRange(101, 124))
      ..enqueuePostFailure(
        siteUrl: FakeBooruBackend.siteUrl,
        query: '',
        page: 2,
        error: AppError(
          type: AppErrorType.cannotReachServer,
          message: 'page two unavailable',
        ),
      )
      ..enqueuePosts(page: 1, posts: testPostRange(101, 124))
      ..enqueuePosts(page: 2, posts: testPostRange(125, 148))
      ..enqueuePosts(page: 3, posts: const []);
    final harness = await _mount(tester, backend);
    final driver = AppFlowDriver(tester: tester, harness: harness);

    await harness.pumpUntil(
      tester,
      () => postController(tester).allItems.length == 24,
      description: 'initial page one to load',
    );
    await driver.scrollToLoadPage(2);
    await harness.pumpUntilFound(tester, find.byType(ErrorBox));
    expect(postController(tester).errors.value, isA<AppError>());
    expect(_pages(backend), [1, 2]);

    await tester.tap(find.text(appStrings(tester).generic.action.retry));
    await harness.pumpUntil(
      tester,
      () =>
          _pages(backend).where((page) => page == 1).length == 2 &&
          postController(tester).allItems.length == 24 &&
          postController(tester).errors.value == null,
      description: 'retry control to perform the page-one refresh',
    );
    expect(_pages(backend), [1, 2, 1]);

    await driver.scrollToLoadPage(2);
    await harness.pumpUntil(
      tester,
      () => postController(tester).allItems.length == 48,
      description: 'a second page two attempt to recover',
    );
    await driver.scrollToLoadPage(3);
    await harness.pumpUntil(
      tester,
      () => !postController(tester).hasMore && !postController(tester).loading,
      description: 'terminal empty response after page-two recovery',
    );
    expect(_pages(backend), [1, 2, 1, 2, 3]);
    expect(loadedPostIds(tester), [for (var id = 101; id <= 148; id++) id]);
  });

  testWidgets(
    'empty search result is distinct from failure and later search works',
    (tester) async {
      final backend = FakeBooruBackend(strictPostScripts: true)
        ..enqueuePosts(page: 1, posts: const [])
        ..enqueuePosts(page: 1, query: 'empty', posts: const [])
        ..enqueuePosts(page: 1, query: 'cat', posts: [TestPost(id: 101)]);
      final harness = await _mount(tester, backend);
      final driver = AppFlowDriver(tester: tester, harness: harness);

      await harness.pumpUntil(
        tester,
        () => _requests(backend).any((r) => r.page == 1 && r.completed),
        description: 'home listing to complete',
      );
      await driver.openSearch();
      await driver.submitSearch('empty');
      await harness.pumpUntil(
        tester,
        () =>
            _requests(backend).any((r) => r.query == 'empty' && r.completed) &&
            postController(tester).allItems.isEmpty,
        description: 'successful empty search to display no results',
      );
      expect(find.byType(ErrorBox), findsNothing);
      expect(postController(tester).errors.value, isNull);
      expect(find.byType(SliverPostGridImageGridItem), findsNothing);

      await driver.clearSelectedSearchTags();
      await driver.submitSearch('cat');
      await harness.pumpUntil(
        tester,
        () =>
            _requests(backend).any((r) => r.query == 'cat' && r.completed) &&
            postController(tester).allItems.length == 1,
        description: 'subsequent cat search to load a result',
      );
      expect(find.byType(ErrorBox), findsNothing);
      expect(find.byType(SliverPostGridImageGridItem), findsOneWidget);
      expect(loadedPostIds(tester), [101]);
    },
  );

  testWidgets(
    'a query submitted during a gated request discards the stale response',
    (tester) async {
      final backend = FakeBooruBackend(strictPostScripts: true)
        ..enqueuePosts(page: 1, posts: const []);
      final catGate = backend.enqueuePostGate(
        siteUrl: backend.config.url,
        query: 'cat',
        page: 1,
      );
      backend.enqueuePosts(
        page: 1,
        query: 'dog',
        posts: [
          TestPost(id: 102, tags: const {'dog'}),
        ],
      );
      final harness = await _mount(tester, backend);
      final driver = AppFlowDriver(tester: tester, harness: harness);

      await harness.pumpUntil(
        tester,
        () => _requests(backend).any((request) => request.completed),
        description: 'home empty response to complete',
      );
      await driver.openSearch();
      await driver.submitSearch('cat');
      await harness.pumpUntil(
        tester,
        () => _requests(backend).any((r) => r.query == 'cat' && r.pending),
        description: 'cat request to remain in flight',
      );
      final catRequest = _requests(backend).lastWhere((r) => r.query == 'cat');

      await driver.clearSelectedSearchTags();
      await driver.submitSearch('dog', waitForRequest: false);
      expect(
        _requests(backend).where((request) => request.query == 'dog'),
        isEmpty,
        reason: 'the listing controller serializes refreshes',
      );

      catGate.completeSuccess(
        testPostResult([
          TestPost(id: 101, tags: const {'cat'}),
        ]),
      );
      await harness.pumpUntil(
        tester,
        () =>
            _requests(backend).any((r) => r.query == 'dog' && r.completed) &&
            loadedPostIds(tester).singleOrNull == 102,
        description: 'queued dog refresh to replace the stale cat completion',
      );

      final dogRequest = _requests(backend).singleWhere(
        (request) => request.query == 'dog',
      );
      expect(dogRequest.id, greaterThan(catRequest.id));
      expect(
        backend.postCompletions,
        containsAllInOrder([catRequest.id, dogRequest.id]),
      );
      expect(loadedPostIds(tester), [102]);
      expect(postController(tester).errors.value, isNull);
      expect(postController(tester).refreshing, isFalse);
      expect(_selectedSearchTags(tester), ['dog']);
    },
  );

  testWidgets(
    'a late response from the old profile cannot replace selected profile data',
    (tester) async {
      final backend = FakeBooruBackend(strictPostScripts: true);
      final aGate = backend.enqueuePostGate(
        siteUrl: backend.config.url,
        query: '',
        page: 1,
      );
      backend.enqueuePosts(
        siteUrl: backend.configB.url,
        page: 1,
        posts: [
          TestPost(id: 101, tags: const {'profile_b'}),
        ],
      );
      final harness = await HeadlessAppHarness.mount(
        tester,
        booruBackend: backend,
        viewportSize: kMobileViewport,
        runtime: backend.createRuntime(
          configs: [backend.config, backend.configB],
          settings: Settings.defaultSettings.copyWith(
            booruConfigSelectorPosition: BooruConfigSelectorPosition.bottom,
          ),
        ),
      );

      await harness.pumpUntil(
        tester,
        () => _requests(backend).isNotEmpty,
        description: 'profile A request to start and remain gated',
      );
      await AppFlowDriver(
        tester: tester,
        harness: harness,
      ).selectProfile(backend.configB);
      await harness.pumpUntil(
        tester,
        () => postController(tester).allItems.length == 1,
        description: 'profile B response to render',
      );
      expect(postController(tester).allItems.single.tags, {'profile_b'});

      aGate.completeSuccess(
        testPostResult([
          TestPost(id: 101, tags: const {'profile_a'}),
        ]),
      );
      await harness.pumpUntil(
        tester,
        () => _requests(backend).single.completed,
        description: 'the stale profile A response to complete',
      );
      await tester.pump(const Duration(milliseconds: 100));

      final container = ProviderScope.containerOf(
        tester.element(postGrid().first),
      );
      expect(
        container.read(currentBooruConfigProvider).url,
        backend.configB.url,
      );
      expect(postController(tester).allItems.single.tags, {'profile_b'});
      expect(
        listingPostWithTag('profile_b'),
        findsOneWidget,
      );
      expect(listingPostWithTag('profile_a'), findsNothing);
    },
  );
}

Future<HeadlessAppHarness> _mount(
  WidgetTester tester,
  FakeBooruBackend backend,
) => HeadlessAppHarness.mount(
  tester,
  booruBackend: backend,
  viewportSize: kMobileViewport,
);

/// Post requests sent to the primary profile's site.
List<FakeBooruPostRequest> _requests(FakeBooruBackend backend) => backend
    .requests
    .whereType<FakeBooruPostRequest>()
    .where((request) => request.siteUrl == FakeBooruBackend.siteUrl)
    .toList();

List<int> _pages(FakeBooruBackend backend) =>
    _requests(backend).map((request) => request.page).toList();

List<String> _selectedSearchTags(WidgetTester tester) => tester
    .widgetList<SelectedTagChip>(find.byType(SelectedTagChip))
    .map((chip) => chip.tagSearchItem.tag)
    .toList();
