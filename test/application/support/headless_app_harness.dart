// Flutter imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  const HeadlessAppHarness._(
    this.runtime,
    this.booruBackend,
    this.additionalOverrides,
  );

  final BoorusamaRuntime runtime;
  final FakeBooruBackend booruBackend;
  final List<Override> additionalOverrides;

  Future<void> pump(WidgetTester tester) async {
    await tester.pumpWidget(
      BoorusamaAppScope(
        runtime: runtime,
        additionalOverrides: additionalOverrides,
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

  void dispose() {}
}
