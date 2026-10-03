import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

import 'package:boorusama/core/ddos/handler/providers.dart';
import 'package:boorusama/core/download_manager/providers.dart';
import 'package:boorusama/core/download_manager/src/l10n.dart';
import 'package:boorusama/core/download_manager/src/pages/download_manager_page.dart';
import 'package:boorusama/core/download_manager/src/providers/internal_providers.dart';
import 'package:boorusama/core/download_manager/src/widgets/download_filter_options.dart';
import 'package:boorusama/core/download_manager/src/widgets/simple_download_tile.dart';
import 'package:boorusama/core/download_manager/types.dart';
import 'package:boorusama/core/downloads/downloader/providers.dart';
import 'package:boorusama/core/home/src/widgets/home_search_bar.dart';
import 'package:boorusama/core/http/client/providers.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/posts/details_parts/widgets.dart';

import 'support/app_flow_driver.dart';
import 'support/app_flow_finders.dart';
import 'support/controlled_download_service.dart';
import 'support/download_event_driver.dart';
import 'support/fake_booru_backend.dart';
import 'support/fake_download_task_client.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets('downloads a post, tracks progress and reopens completed task', (
    tester,
  ) async {
    final flow = await _DownloadFlow.mount(tester);

    await flow.enqueuePost(101);
    final options = flow.downloads.requests.single;
    final task = flow.downloads.taskAt(0);
    expect(options.url, 'https://headless.booru.test/posts/101.jpg');
    expect(options.filename, task.filename);
    expect(options.filename, endsWith('.jpg'));
    expect(options.metadata?.siteUrl, flow.backend.config.url);
    expect(options.metadata?.fileSize, flow.backend.posts.first.fileSize);
    expect(
      tester.takeException(),
      isNull,
      reason: 'post details should fit the 390px mobile viewport',
    );

    await flow.openManager();
    flow.events.status(task, bg.TaskStatus.enqueued);
    await flow.selectFilter(DownloadFilter.pending);
    await flow.expectTaskVisible(task.taskId);

    await flow.selectFilter(DownloadFilter.inProgress);
    flow.events
      ..status(task, bg.TaskStatus.running)
      ..progress(task, 0.25);
    await flow.harness.pumpUntilFound(tester, flow.inRow(task, '25%'));
    flow.events.progress(task, 0.75);
    await flow.harness.pumpUntilFound(tester, flow.inRow(task, '75%'));

    flow.client.filePaths[task.taskId] = '/virtual/downloads/post-101.jpg';
    flow.events.status(task, bg.TaskStatus.complete);
    await flow.selectFilter(DownloadFilter.completed);
    await flow.harness.pumpUntil(
      tester,
      () => flow.client.actions.any(
        (action) =>
            action.taskId == task.taskId &&
            action.operation == DownloadTaskOperation.filePath,
      ),
      description: 'fake path lookup for completed task ${task.taskId}',
    );
    expect(
      find.descendant(
        of: flow.taskRow(task.taskId),
        matching: find.byIcon(Symbols.download_done),
      ),
      findsOneWidget,
    );

    await flow.driver.goBack();
    await flow.openManager();
    await flow.selectFilter(DownloadFilter.completed);
    await flow.expectTaskVisible(task.taskId);
    expect(flow.downloads.requests, hasLength(1));
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed non-resumable task retries with refreshed headers', (
    tester,
  ) async {
    final flow = await _DownloadFlow.mount(tester);

    await flow.enqueuePost(101);
    final task = flow.downloads.taskAt(0);
    await flow.openManager();
    await flow.failTask(task);
    await flow.selectFilter(DownloadFilter.failed);
    final retryButton = find.descendant(
      of: flow.taskRow(task.taskId),
      matching: find.byIcon(Symbols.refresh),
    );
    await flow.harness.pumpUntilFound(tester, retryButton);
    expect(flow.client.resumableTaskIds, isNot(contains(task.taskId)));

    final readsBeforeRetry = flow.bypassReads[task.url] ?? 0;
    await tester.tap(retryButton);
    await flow.harness.pumpUntil(
      tester,
      () => flow.client.controlsFor(task.taskId).isNotEmpty,
      description: 'native retry for ${task.taskId}',
    );

    final retry = flow.client.lastControl(task.taskId);
    expect(flow.client.controlsFor(task.taskId), [DownloadTaskOperation.retry]);
    expect(retry.headers, {'x-test-profile': flow.backend.config.url});
    expect(retry.bypassHeaders, {
      'x-test-clearance': flow.lastBypassHeaders[task.url],
    });
    expect(flow.bypassReads[task.url], greaterThan(readsBeforeRetry));
    expect(flow.downloads.requests, hasLength(1));

    await flow.selectFilter(DownloadFilter.inProgress);
    flow.events
      ..status(task, bg.TaskStatus.running)
      ..progress(task, 0.4);
    await flow.expectTaskVisible(task.taskId);
    flow.events.status(task, bg.TaskStatus.complete);
    await flow.selectFilter(DownloadFilter.completed);
    await flow.expectTaskVisible(task.taskId);
    expect(tester.takeException(), isNull);
  });

  testWidgets('failed resumable task uses resume and recovers', (
    tester,
  ) async {
    final flow = await _DownloadFlow.mount(tester);

    await flow.enqueuePost(101);
    final task = flow.downloads.taskAt(0);
    flow.client.resumableTaskIds.add(task.taskId);
    await flow.openManager();
    await flow.failTask(task);
    await flow.selectFilter(DownloadFilter.failed);
    final retryButton = find.descendant(
      of: flow.taskRow(task.taskId),
      matching: find.byIcon(Symbols.refresh),
    );
    await flow.harness.pumpUntilFound(tester, retryButton);
    await tester.tap(retryButton);
    await flow.harness.pumpUntil(
      tester,
      () => flow.client.controlsFor(task.taskId).isNotEmpty,
      description: 'resume for resumable task ${task.taskId}',
    );
    expect(flow.client.controlsFor(task.taskId), [
      DownloadTaskOperation.resume,
    ]);

    await flow.selectFilter(DownloadFilter.inProgress);
    flow.events
      ..status(task, bg.TaskStatus.running)
      ..progress(task, 0.5);
    await flow.expectTaskVisible(task.taskId);
    flow.events.status(task, bg.TaskStatus.complete);
    await flow.selectFilter(DownloadFilter.completed);
    await flow.expectTaskVisible(task.taskId);
    expect(flow.client.controlsFor(task.taskId), [
      DownloadTaskOperation.resume,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('pauses, resumes, then cancels from visible task controls', (
    tester,
  ) async {
    final flow = await _DownloadFlow.mount(tester);

    await flow.enqueuePost(101);
    final task = flow.downloads.taskAt(0);
    await flow.openManager();
    flow.events
      ..status(task, bg.TaskStatus.running)
      ..progress(task, 0.35);
    await flow.expectTaskVisible(task.taskId);

    final pause = find
        .descendant(
          of: flow.taskRow(task.taskId),
          matching: find.byIcon(Symbols.pause),
        )
        .hitTestable();
    await tester.tap(pause.first);
    await flow.waitForControl(task, DownloadTaskOperation.pause);
    flow.events.status(task, bg.TaskStatus.paused);
    await flow.selectFilter(DownloadFilter.paused);
    await flow.expectTaskVisible(task.taskId);

    await tester.tap(
      find.descendant(
        of: flow.taskRow(task.taskId),
        matching: find.byIcon(Symbols.play_arrow),
      ),
    );
    await flow.waitForControl(task, DownloadTaskOperation.resume);
    flow.events
      ..status(task, bg.TaskStatus.running)
      ..progress(task, 0.55);
    await flow.selectFilter(DownloadFilter.inProgress);
    await flow.expectTaskVisible(task.taskId);

    final cancelLabel = appStrings(tester).generic.action.cancel;
    await tester.tap(flow.inRow(task, cancelLabel));
    await flow.waitForControl(task, DownloadTaskOperation.cancel);
    flow.events.status(task, bg.TaskStatus.canceled);
    await flow.selectFilter(DownloadFilter.canceled);
    await flow.expectTaskVisible(task.taskId);
    expect(flow.inRow(task, cancelLabel), findsNothing);
    expect(
      find.descendant(
        of: flow.taskRow(task.taskId),
        matching: find.byIcon(Symbols.pause),
      ),
      findsNothing,
    );
    expect(flow.client.controlsFor(task.taskId), [
      DownloadTaskOperation.pause,
      DownloadTaskOperation.resume,
      DownloadTaskOperation.cancel,
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('filters independent tasks without issuing task actions', (
    tester,
  ) async {
    final flow = await _DownloadFlow.mount(tester);

    await flow.enqueuePost(101);
    await flow.driver.goBack();
    await flow.enqueuePost(102);
    await flow.driver.goBack();
    await flow.enqueuePost(101);
    expect(flow.downloads.taskIds.toSet(), hasLength(3));

    final [completed, failed, canceled] = [
      for (var i = 0; i < 3; i++) flow.downloads.taskAt(i),
    ];
    await flow.openManager();
    flow.events
      ..status(completed, bg.TaskStatus.complete)
      ..status(canceled, bg.TaskStatus.canceled);
    await flow.failTask(failed);

    final expectedByFilter = {
      DownloadFilter.completed: [completed.taskId],
      DownloadFilter.failed: [failed.taskId],
      DownloadFilter.canceled: [canceled.taskId],
      DownloadFilter.inProgress: <String>[],
    };
    for (final MapEntry(key: filter, value: taskIds)
        in expectedByFilter.entries) {
      await flow.selectFilter(filter);
      await flow.expectOnlyTasks(taskIds);
    }

    // Revisit every status without new platform events: the records must
    // survive the filter changes rather than being rebuilt by fresh updates.
    final eventsBeforeRevisit = flow.events.events.length;
    for (final MapEntry(key: filter, value: taskIds)
        in expectedByFilter.entries.toList().reversed) {
      await flow.selectFilter(filter);
      await flow.expectOnlyTasks(taskIds);
    }
    expect(flow.events.events, hasLength(eventsBeforeRevisit));

    for (final task in [completed, failed, canceled]) {
      expect(flow.client.controlsFor(task.taskId), isEmpty);
    }
    expect(flow.downloads.requests, hasLength(3));
    expect(tester.takeException(), isNull);
  });
}

final class _DownloadFlow {
  _DownloadFlow._(this.tester)
    : backend = FakeBooruBackend(),
      downloads = ControlledDownloadService(),
      client = FakeDownloadTaskClient() {
    harness = HeadlessAppHarness(
      booruBackend: backend,
      runtime: backend.createRuntime(downloadService: downloads),
      viewportSize: kMobileViewport,
      additionalOverrides: [
        downloadServiceProvider.overrideWithValue(downloads),
        downloadTaskClientProvider.overrideWithValue(client),
        httpHeadersProvider.overrideWith(
          (ref, config) => {'x-test-profile': config.url},
        ),
        bypassDdosHeadersProvider.overrideWith((ref, url) {
          final count = (bypassReads[url] ?? 0) + 1;
          bypassReads[url] = count;
          lastBypassHeaders[url] = 'fresh-$count';
          return Future.value({'x-test-clearance': 'fresh-$count'});
        }),
      ],
    );
    driver = AppFlowDriver(tester: tester, harness: harness);
  }

  static Future<_DownloadFlow> mount(WidgetTester tester) async {
    final flow = _DownloadFlow._(tester);
    addTearDown(() => flow.harness.teardown(tester));
    await flow.harness.pump(tester);
    return flow;
  }

  final WidgetTester tester;
  final FakeBooruBackend backend;
  final ControlledDownloadService downloads;
  final FakeDownloadTaskClient client;
  final bypassReads = <String, int>{};
  final lastBypassHeaders = <String, String>{};
  late final HeadlessAppHarness harness;
  late final AppFlowDriver driver;
  DownloadEventDriver? _events;

  DownloadEventDriver get events => _events ??= DownloadEventDriver(
    ProviderScope.containerOf(
      tester.element(
        switch (find.byType(DownloadManagerPage)) {
          final page when page.evaluate().isNotEmpty => page.first,
          _ => find.byType(HomeSearchBar).first,
        },
      ),
    ),
  );

  Future<void> enqueuePost(int postId) async {
    await driver.openPost(postId);
    await harness.pumpUntilFound(tester, find.byType(DownloadPostButton));
    final button = find.byType(DownloadPostButton).first;
    await tester.ensureVisible(button);
    final expectedCount = downloads.requests.length + 1;
    await tester.tap(button);
    await harness.pumpUntil(
      tester,
      () => downloads.requests.length == expectedCount,
      description: 'download service to enqueue post $postId',
    );
  }

  Future<void> openManager() async {
    if (find.byType(PostDetailsPageScaffold).evaluate().isNotEmpty) {
      await driver.goBack();
    }
    await driver.openDownloadManager();
    await harness.pumpUntil(
      tester,
      () {
        final page = find.byType(DownloadManagerPage);
        if (page.evaluate().isEmpty) return false;
        final rect = tester.getRect(page.first);
        return rect.left >= 0 && rect.right <= tester.view.physicalSize.width;
      },
      description: 'download manager page to finish its route transition',
    );
    expect(
      tester.takeException(),
      isNull,
      reason: 'the normal download manager entry must fit the mobile drawer',
    );
  }

  /// Publishes a failure and waits out the error toast the app shows for it.
  /// The toast has a fixed five-second lifetime that ignores the test toast
  /// duration, so it must expire before the next step and before teardown.
  Future<void> failTask(bg.DownloadTask task) async {
    events.status(task, bg.TaskStatus.failed);
    final toast = find.text('Download failed: ${task.filename}');
    await harness.pumpUntilFound(tester, toast);
    await harness.pumpUntil(
      tester,
      () => toast.evaluate().isEmpty,
      description: 'failure toast for ${task.taskId} to expire',
      maxPumps: 120,
    );
  }

  Finder taskRow(String taskId) => find.byWidgetPredicate(
    (widget) =>
        widget is SimpleDownloadTile && widget.task.task.taskId == taskId,
    description: 'download task row $taskId',
  );

  Finder inRow(bg.DownloadTask task, String text) =>
      find.descendant(of: taskRow(task.taskId), matching: find.text(text));

  Future<void> expectTaskVisible(String taskId) =>
      harness.pumpUntilFound(tester, taskRow(taskId));

  Future<void> expectOnlyTasks(List<String> taskIds) async {
    await harness.pumpUntil(
      tester,
      () => downloads.taskIds.every(
        (id) => taskRow(id).evaluate().isNotEmpty == taskIds.contains(id),
      ),
      description: 'exactly task rows $taskIds to be visible',
    );
  }

  Future<void> waitForControl(
    bg.DownloadTask task,
    DownloadTaskOperation operation,
  ) => harness.pumpUntil(
    tester,
    () => client.controlsFor(task.taskId).lastOrNull == operation,
    description: '${operation.name} for ${task.taskId}',
  );

  Future<void> selectFilter(DownloadFilter filter) async {
    final options = find.byType(DownloadFilterOptions);
    await harness.pumpUntilFound(tester, options);
    final label = filter.localize(tester.element(options));
    final chip = find.descendant(
      of: options,
      matching: find.bySemanticsLabel(label),
    );
    final row = find.descendant(of: options, matching: find.byType(Scrollable));

    // Rewind the chip row so the target is always reached by scrolling forward.
    await tester.fling(row.first, const Offset(2000, 0), 5000);
    await tester.pump(const Duration(milliseconds: 400));
    await tester.scrollUntilVisible(
      chip.hitTestable(),
      150,
      scrollable: row.first,
    );
    await tester.tap(chip.hitTestable());

    final optionsWidget = tester.widget<DownloadFilterOptions>(options);
    final container = ProviderScope.containerOf(tester.element(options));
    await harness.pumpUntil(
      tester,
      () =>
          container.read(downloadFilterProvider(optionsWidget.filter)) ==
          filter,
      description: 'download filter $filter to be selected',
    );
  }
}
