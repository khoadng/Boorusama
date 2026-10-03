// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:background_downloader/background_downloader.dart' as bg;
import 'package:cache_manager/cache_manager.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:go_router/go_router.dart';

// Project imports:
import 'package:boorusama/core/announcements/providers.dart';
import 'package:boorusama/core/app.dart';
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/download_manager/providers.dart';
import 'package:boorusama/core/download_manager/src/pages/download_manager_page.dart';
import 'package:boorusama/core/download_manager/types.dart';
import 'package:boorusama/core/images/providers.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';

import 'fake_booru_backend.dart';

/// Logical size used by the phone-layout journeys.
const kMobileViewport = Size(390, 844);

final class HeadlessAppHarness {
  factory HeadlessAppHarness({
    BoorusamaRuntime? runtime,
    FakeBooruBackend? booruBackend,
    List<Override> additionalOverrides = const [],
    Size? viewportSize,
  }) {
    final backend = booruBackend ?? FakeBooruBackend();
    return HeadlessAppHarness._(
      runtime ?? backend.createRuntime(),
      backend,
      additionalOverrides,
      viewportSize,
    );
  }

  HeadlessAppHarness._(
    this.runtime,
    this.booruBackend,
    this.additionalOverrides,
    this.viewportSize,
  );

  /// Creates a harness, registers its teardown, and mounts the app.
  static Future<HeadlessAppHarness> mount(
    WidgetTester tester, {
    BoorusamaRuntime? runtime,
    FakeBooruBackend? booruBackend,
    List<Override> additionalOverrides = const [],
    Size? viewportSize,
  }) async {
    final harness = HeadlessAppHarness(
      runtime: runtime,
      booruBackend: booruBackend,
      additionalOverrides: additionalOverrides,
      viewportSize: viewportSize,
    );
    addTearDown(() => harness.teardown(tester));
    _stubDownloaderChannel(tester);
    await harness.pump(tester);
    return harness;
  }

  /// The downloader configures itself at startup; without a stub that call
  /// fails as soon as a test lets real async work run.
  static void _stubDownloaderChannel(WidgetTester tester) {
    const channel = MethodChannel('com.bbflight.background_downloader');
    final messenger = tester.binding.defaultBinaryMessenger
      ..setMockMethodCallHandler(channel, (_) async => null);
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));
  }

  final BoorusamaRuntime runtime;
  final FakeBooruBackend booruBackend;
  final List<Override> additionalOverrides;
  final Size? viewportSize;
  var _didTearDown = false;

  /// The image cache writes through dart:io, which the in-memory test file
  /// system cannot back, so it gets a real throwaway directory.
  late final _imageCacheDirectory = Directory.systemTemp.createTempSync(
    'boorusama_images_',
  );
  var _didConfigureViewport = false;
  Duration? _previousVisibilityUpdateInterval;

  Future<void> pump(WidgetTester tester) async {
    final size = viewportSize;
    if (size != null) setViewport(tester, size);
    final visibilityController = VisibilityDetectorController.instance;
    _previousVisibilityUpdateInterval ??= visibilityController.updateInterval;
    visibilityController.updateInterval = Duration.zero;

    await tester.pumpWidget(
      BoorusamaAppScope(
        runtime: runtime,
        additionalOverrides: [
          appAnnouncementsProvider.overrideWith(
            (ref) => Future.value(const []),
          ),
          defaultImageCacheManagerProvider.overrideWith((ref) {
            final manager = DefaultImageCacheManager(
              cacheRootPathProvider: () =>
                  Future.value(_imageCacheDirectory.path),
            );
            ref.onDispose(manager.dispose);
            return manager;
          }),
          ...additionalOverrides,
          toastDurationProvider.overrideWithValue(Duration.zero),
        ],
        child: const BoorusamaCoreApp(),
      ),
    );
    await tester.pump();
  }

  Future<void> settle(
    WidgetTester tester, {
    int maxPumps = 20,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      await tester.pump(step);
      if (!tester.binding.hasScheduledFrame) return;
    }
  }

  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    int maxPumps = 80,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    await pumpUntil(
      tester,
      () => finder.evaluate().isNotEmpty,
      description: 'widget $finder',
      maxPumps: maxPumps,
      step: step,
    );
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() condition, {
    int maxPumps = 80,
    Duration step = const Duration(milliseconds: 50),
    String description = 'application state condition',
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      if (condition()) return;
      await tester.pump(step);
    }

    if (condition()) return;
    throw TestFailure(
      'Timed out waiting for $description after $maxPumps pumps. '
      '${_diagnostics(tester, description)}',
    );
  }

  void setViewport(
    WidgetTester tester,
    Size size, {
    double pixelRatio = 1,
  }) {
    if (!_didConfigureViewport) {
      _didConfigureViewport = true;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
    }
    tester.view
      ..devicePixelRatio = pixelRatio
      ..physicalSize = size;
  }

  String _diagnostics(WidgetTester tester, String expected) {
    var route = 'unknown';
    try {
      final navigator = find.byType(Navigator).first;
      route = GoRouter.of(tester.element(navigator))
          .routeInformationProvider
          .value
          .uri
          .toString();
    } on Object catch (_) {}

    final recentRequests = booruBackend.requests
        .whereType<FakeBooruPostRequest>()
        .toList(growable: false)
        .reversed
        .take(8)
        .map(
          (request) =>
              '#${request.id} ${request.siteUrl} q="${request.query}" '
              'p=${request.page} ${request.pending ? 'pending' : 'done'} '
              'ids=${request.resultIds} error=${request.error}',
        )
        .toList(growable: false);
    final pendingGates = booruBackend.pendingPostGates
        .where((gate) => !gate.isCompleted)
        .length;
    final taskStatuses = <String>[];
    try {
      final page = find.byType(DownloadManagerPage);
      final scope = page.evaluate().isNotEmpty
          ? page.first
          : find.byType(BoorusamaCoreApp).first;
      final state = ProviderScope.containerOf(
        tester.element(scope),
      ).read(downloadTaskUpdatesProvider);
      for (final entry in state.tasks.entries) {
        for (final update in entry.value) {
          final status = switch (update) {
            final bg.TaskStatusUpdate update => update.status.name,
            final bg.TaskProgressUpdate update =>
              '${(update.progress * 100).round()}%',
          };
          taskStatuses.add('${entry.key}/${update.task.taskId}:$status');
        }
      }
    } on Object catch (_) {}

    return 'expected=$expected, route=$route, '
        'recentRequests=$recentRequests, pendingGates=$pendingGates, '
        'tasks=$taskStatuses';
  }

  Future<void> openFirstPost(WidgetTester tester) async {
    await pumpUntilFound(
      tester,
      find.byType(SliverPostGridImageGridItem),
    );
    await tester.tap(find.byType(SliverPostGridImageGridItem).first);
    await tester.pump();
    await pumpUntilFound(tester, find.byType(PostDetailsPageScaffold));
  }

  void dispose() {
    dismissAllToast();
    booruBackend.cancelPendingPostGates();
  }

  Future<void> teardown(WidgetTester tester) async {
    if (_didTearDown) return;

    dispose();
    await tester.pumpWidget(const SizedBox());
    final visibilityController = VisibilityDetectorController.instance;
    visibilityController.notifyNow();
    await tester.pump();
    final previousInterval = _previousVisibilityUpdateInterval;
    if (previousInterval != null) {
      visibilityController.updateInterval = previousInterval;
    }
    _didTearDown = true;
    if (_imageCacheDirectory.existsSync()) {
      _imageCacheDirectory.deleteSync(recursive: true);
    }
    booruBackend.expectNoUnexpectedPostRequests();
  }
}
