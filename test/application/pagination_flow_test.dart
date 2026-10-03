import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:boorusama/core/posts/listing/widgets.dart';

import 'support/app_flow_driver.dart';
import 'support/app_flow_finders.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets('appends pages and stops after terminal empty response', (
    tester,
  ) async {
    final backend = FakeBooruBackend(strictPostScripts: true)
      ..enqueuePosts(page: 1, posts: testPostRange(101, 124))
      ..enqueuePosts(page: 2, posts: testPostRange(125, 148))
      ..enqueuePosts(page: 3, posts: const []);
    final flow = await _mount(tester, backend);

    await flow.waitForPage(1, count: 24);
    expect(loadedPostIds(tester), _ids(101, 124));

    await flow.driver.scrollToLoadPage(2);
    await flow.waitForCount(48, 'page two to append 24 posts');
    expect(loadedPostIds(tester), _ids(101, 148));
    await tester.scrollUntilVisible(
      postTile(148),
      350,
      scrollable: postGridScrollable(),
    );
    expect(postTile(148), findsOneWidget);

    await flow.driver.scrollToLoadPage(3);
    await flow.waitForExhausted(
      'the empty page three response to end infinite scrolling',
    );
    expect(loadedPostIds(tester), _ids(101, 148));
    expect(find.byType(SliverPostGridImageGridItem), findsWidgets);

    for (var i = 0; i < 3; i++) {
      await tester.fling(postGridScrollable(), const Offset(0, -1800), 7000);
      await tester.pump(const Duration(milliseconds: 600));
    }
    expect(flow.listingPages, [1, 2, 3]);
    expect(find.byType(SliverPostGridImageGridItem), findsWidgets);
  });

  testWidgets(
    'removes the overlapping boundary post and opens page two identity',
    (tester) async {
      final backend = FakeBooruBackend(strictPostScripts: true)
        ..enqueuePosts(page: 1, posts: testPostRange(101, 124))
        ..enqueuePosts(page: 2, posts: testPostRange(124, 147))
        ..enqueuePosts(page: 3, posts: const []);
      final flow = await _mount(tester, backend);

      await flow.waitForPage(1, count: 24);
      await flow.driver.scrollToLoadPage(2);
      await flow.waitForCount(47, 'overlapping page two to add 23 posts');

      final ids = loadedPostIds(tester);
      expect(ids, _ids(101, 147));
      expect(ids.where((id) => id == 124), hasLength(1));

      await flow.driver.openPost(147);
      expect(currentDetailPost(tester).id, 147);
    },
  );

  testWidgets('refresh replaces exhausted data and restarts at page one', (
    tester,
  ) async {
    final backend = FakeBooruBackend(strictPostScripts: true)
      ..enqueuePosts(page: 1, posts: testPostRange(101, 124))
      ..enqueuePosts(page: 2, posts: testPostRange(125, 148))
      ..enqueuePosts(page: 3, posts: const [])
      ..enqueuePosts(page: 1, posts: testPostRange(201, 224))
      ..enqueuePosts(page: 2, posts: testPostRange(225, 248))
      ..enqueuePosts(page: 3, posts: const []);
    final flow = await _mount(tester, backend);

    await flow.waitForPage(1, count: 24);
    await flow.driver.scrollToLoadPage(2);
    await flow.waitForCount(48, 'initial page two to append');
    await flow.driver.scrollToLoadPage(3);
    await flow.waitForExhausted('initial listing to become exhausted');

    await tester.sendKeyEvent(LogicalKeyboardKey.f5);
    await flow.harness.pumpUntil(
      tester,
      () =>
          flow.listingPages.where((page) => page == 1).length == 2 &&
          loadedPostIds(tester).firstOrNull == 201,
      description: 'keyboard refresh to replace the listing with page one',
    );
    final controller = postController(tester);
    expect(loadedPostIds(tester), _ids(201, 224));
    expect(controller.page, 1);
    expect(controller.hasMore, isTrue);

    await flow.driver.scrollToLoadPage(2);
    await flow.waitForCount(48, 'refreshed page two to load');
    expect(loadedPostIds(tester), _ids(201, 248));
    await flow.driver.scrollToLoadPage(3);
    await flow.waitForExhausted('refreshed terminal page to exhaust the list');
  });

  testWidgets('repeated bottom scrolling keeps one in-flight page request', (
    tester,
  ) async {
    final backend = FakeBooruBackend(strictPostScripts: true)
      ..enqueuePosts(page: 1, posts: testPostRange(101, 124));
    final gate = backend.enqueuePostGate(
      siteUrl: backend.config.url,
      query: '',
      page: 2,
    );
    backend.enqueuePosts(page: 3, posts: const []);
    final flow = await _mount(tester, backend);

    await flow.waitForPage(1, count: 24);
    await flow.driver.scrollToLoadPage(2);
    final pageTwo = flow.listingRequests.where((request) => request.page == 2);
    expect(pageTwo.single.pending, isTrue);

    for (var i = 0; i < 4; i++) {
      await tester.fling(postGridScrollable(), const Offset(0, -2400), 9000);
      await tester.pump(const Duration(milliseconds: 600));
    }
    expect(flow.listingPages, [1, 2]);
    expect(postController(tester).allItems, hasLength(24));

    gate.completeSuccess(testPostResult(testPostRange(125, 148)));
    await flow.waitForCount(48, 'gated page two to append once after release');
    expect(loadedPostIds(tester).where((id) => id == 125), hasLength(1));

    await flow.driver.scrollToLoadPage(3);
    await flow.waitForExhausted('the next eligible request to be page three');
    expect(flow.listingPages, [1, 2, 3]);
  });
}

List<int> _ids(int first, int last) => [for (var i = first; i <= last; i++) i];

Future<_PaginationFlow> _mount(
  WidgetTester tester,
  FakeBooruBackend backend,
) async {
  final harness = await HeadlessAppHarness.mount(
    tester,
    booruBackend: backend,
    viewportSize: kMobileViewport,
  );
  return _PaginationFlow(tester, harness);
}

final class _PaginationFlow {
  _PaginationFlow(this.tester, this.harness)
    : driver = AppFlowDriver(tester: tester, harness: harness);

  final WidgetTester tester;
  final HeadlessAppHarness harness;
  final AppFlowDriver driver;

  List<FakeBooruPostRequest> get listingRequests => harness
      .booruBackend
      .requests
      .whereType<FakeBooruPostRequest>()
      .where(
        (request) =>
            request.siteUrl == FakeBooruBackend.siteUrl &&
            request.query.isEmpty,
      )
      .toList();

  List<int> get listingPages =>
      listingRequests.map((request) => request.page).toList();

  Future<void> waitForPage(int page, {required int count}) => harness.pumpUntil(
    tester,
    () =>
        postController(tester).allItems.length == count &&
        listingRequests.any((r) => r.page == page && r.completed),
    description: 'page $page to complete with $count posts',
  );

  Future<void> waitForCount(int count, String description) => harness.pumpUntil(
    tester,
    () => postController(tester).allItems.length == count,
    description: description,
  );

  Future<void> waitForExhausted(String description) => harness.pumpUntil(
    tester,
    () {
      final controller = postController(tester);
      return !controller.hasMore && !controller.loading;
    },
    description: description,
  );
}
