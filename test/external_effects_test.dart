// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/backups/auto/trigger.dart';
import 'package:boorusama/core/debug/data.dart';
import 'package:boorusama/core/debug/src/providers/providers.dart';
import 'package:boorusama/core/debug/widgets.dart';
import 'package:boorusama/core/themes/colors/providers.dart';
import 'package:boorusama/foundation/loggers.dart';
import 'package:boorusama/foundation/networking.dart';

void main() {
  testWidgets('network listener exposes injected connectivity changes', (
    tester,
  ) async {
    final connectivity = ControllableConnectivityService();
    final logger = AppLogger();
    final container = ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(connectivity),
        loggerProvider.overrideWithValue(logger),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await connectivity.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const Directionality(
          textDirection: TextDirection.ltr,
          child: NetworkListener(
            child: _NetworkStateText(),
          ),
        ),
      ),
    );
    await tester.pump();

    connectivity.emit(const [ConnectivityResult.wifi]);
    await tester.pump();
    await tester.pump();
    expect(find.text('NetworkConnectedState'), findsOneWidget);

    connectivity.emit(const [ConnectivityResult.none]);
    await tester.pump();
    await tester.pump();
    expect(find.text('NetworkDisconnectedState'), findsOneWidget);
  });

  testWidgets('auto-backup lifecycle invokes its injected launch action', (
    tester,
  ) async {
    var launchCount = 0;

    await tester.pumpWidget(
      AutoBackupAppLifecycle(
        onAppLaunch: () async => launchCount++,
        child: const SizedBox.shrink(),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(launchCount, 1);
  });

  testWidgets('diagnostic context records injected network transports', (
    tester,
  ) async {
    final connectivity = ControllableConnectivityService();
    final logger = AppLogger();
    final container = ProviderContainer(
      overrides: [
        connectivityServiceProvider.overrideWithValue(connectivity),
        appLoggerProvider.overrideWithValue(logger),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await connectivity.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: const DiagnosticContextScope(
          child: SizedBox.shrink(),
        ),
      ),
    );
    await tester.pump();

    connectivity.emit(const [ConnectivityResult.wifi]);
    await tester.pump();
    await tester.pump();

    expect(logger.reportContext['networkTransports'], 'wifi');
  });

  test('dynamic color defaults to the pure no-op scheme', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    expect(
      container.read(dynamicColorSchemesProvider),
      DynamicColorSchemes.none,
    );
  });
}

final class _NetworkStateText extends ConsumerWidget {
  const _NetworkStateText();

  @override
  Widget build(BuildContext context, WidgetRef ref) => Text(
    ref.watch(networkStateProvider).runtimeType.toString(),
  );
}

final class ControllableConnectivityService implements ConnectivityService {
  final _controller = StreamController<List<ConnectivityResult>>.broadcast();

  @override
  Stream<List<ConnectivityResult>> get changes => _controller.stream;

  @override
  Future<List<ConnectivityResult>> getCurrent() async => const [
    ConnectivityResult.wifi,
  ];

  void emit(List<ConnectivityResult> result) => _controller.add(result);

  Future<void> dispose() => _controller.close();
}
