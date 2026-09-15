// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';

// Project imports:
import 'package:boorusama/core/app.dart';
import 'package:boorusama/core/bootstrap/boorusama_bootstrap.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/bootstrap/bootstrap_host.dart';
import 'package:boorusama/foundation/boot/crash_report_writer.dart';

import '../../support/boorusama_test_runtime.dart';

void main() {
  testWidgets('renders the app after bootstrap succeeds', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: BoorusamaBootstrapHost(
          bootstrap: _ImmediateBootstrap(createTestBoorusamaRuntime()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(BoorusamaCoreApp), findsOneWidget);
  });

  testWidgets('renders its loading widget while bootstrap is pending', (
    tester,
  ) async {
    final completer = Completer<BoorusamaRuntime>();
    await tester.pumpWidget(
      MaterialApp(
        home: BoorusamaBootstrapHost(
          bootstrap: _DeferredBootstrap(completer),
          loading: const Text('Loading test'),
        ),
      ),
    );

    expect(find.text('Loading test'), findsOneWidget);
    completer.complete(createTestBoorusamaRuntime());
    await tester.pumpAndSettle();

    expect(find.byType(BoorusamaCoreApp), findsOneWidget);
  });

  testWidgets('renders the crash report UI when bootstrap fails', (
    tester,
  ) async {
    final writer = _RecordingCrashReportWriter();
    await tester.pumpWidget(
      MaterialApp(
        home: BoorusamaBootstrapHost(
          bootstrap: _FailingBootstrap(),
          crashReportWriter: writer,
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.textContaining('test failure'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.download));
    await tester.pump();

    expect(writer.savedData, contains('known test log'));
  });
}

final class _ImmediateBootstrap implements BoorusamaBootstrap {
  const _ImmediateBootstrap(this.runtime);

  final BoorusamaRuntime runtime;

  @override
  Future<BoorusamaRuntime> initialize() async => runtime;
}

final class _DeferredBootstrap implements BoorusamaBootstrap {
  const _DeferredBootstrap(this.completer);

  final Completer<BoorusamaRuntime> completer;

  @override
  Future<BoorusamaRuntime> initialize() => completer.future;
}

final class _FailingBootstrap implements BoorusamaBootstrap {
  @override
  Future<BoorusamaRuntime> initialize() {
    final failure = BoorusamaBootstrapFailure(
      error: StateError('test failure'),
      stackTrace: StackTrace.current,
      logs: 'known test log',
    );
    return Future<BoorusamaRuntime>.error(failure, failure.stackTrace);
  }
}

final class _RecordingCrashReportWriter implements CrashReportWriter {
  String? savedData;

  @override
  Future<void> save(BuildContext context, String data) {
    savedData = data;
    return Future.value();
  }
}
