// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:visibility_detector/visibility_detector.dart';

// Project imports:
import 'package:boorusama/core/app.dart';
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/posts/details/widgets.dart';
import 'package:boorusama/core/posts/listing/widgets.dart';

import 'fake_booru_backend.dart';

final class HeadlessAppHarness {
  factory HeadlessAppHarness({
    BoorusamaRuntime? runtime,
    FakeBooruBackend? booruBackend,
    List<Override> additionalOverrides = const [],
  }) {
    final backend = booruBackend ?? FakeBooruBackend();
    return HeadlessAppHarness._(
      runtime ?? backend.createRuntime(),
      backend,
      additionalOverrides,
    );
  }

  HeadlessAppHarness._(
    this.runtime,
    this.booruBackend,
    this.additionalOverrides,
  );

  final BoorusamaRuntime runtime;
  final FakeBooruBackend booruBackend;
  final List<Override> additionalOverrides;
  var _didTearDown = false;
  Duration? _previousVisibilityUpdateInterval;

  Future<void> pump(WidgetTester tester) async {
    final visibilityController = VisibilityDetectorController.instance;
    _previousVisibilityUpdateInterval ??= visibilityController.updateInterval;
    visibilityController.updateInterval = Duration.zero;

    await tester.pumpWidget(
      BoorusamaAppScope(
        runtime: runtime,
        additionalOverrides: [
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
    int maxPumps = 20,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      if (finder.evaluate().isNotEmpty) return;
      await tester.pump(step);
    }

    throw TestFailure('Timed out waiting for $finder');
  }

  Future<void> pumpUntil(
    WidgetTester tester,
    bool Function() condition, {
    int maxPumps = 20,
    Duration step = const Duration(milliseconds: 50),
  }) async {
    for (var i = 0; i < maxPumps; i++) {
      if (condition()) return;
      await tester.pump(step);
    }

    throw TestFailure('Timed out waiting for the application state');
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
  }
}
