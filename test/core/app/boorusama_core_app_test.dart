// Package imports:
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:kurumi/material.dart';

// Project imports:
import 'package:boorusama/core/app_scope.dart';
import 'package:boorusama/core/bootstrap/boorusama_runtime.dart';
import 'package:boorusama/core/widgets/reboot.dart';
import 'package:boorusama/foundation/applock/src/app_lock_capabilities.dart';
import 'package:boorusama/foundation/networking/network_provider.dart';
import 'package:boorusama/foundation/platform.dart';

import '../../riverpod_test_utils.dart';
import '../../support/boorusama_test_app.dart';
import '../../support/boorusama_test_runtime.dart';

void main() {
  testWidgets(
    'boots with in-memory dependencies without platform setup',
    (tester) async {
      await pumpBoorusamaCoreApp(tester);

      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  test(
    'uses the selected platform from the runtime',
    () {
      final windows = createTestBoorusamaRuntime(
        platform: AppPlatform.windows,
      );
      final android = createTestBoorusamaRuntime(
        platform: AppPlatform.android,
      );

      final windowsContainer = _createRuntimeContainer(windows);
      final androidContainer = _createRuntimeContainer(android);

      expect(
        windowsContainer.read(appLockCapabilitiesProvider).nativePrivacyCover,
        isTrue,
      );
      expect(
        androidContainer.read(appLockCapabilitiesProvider).nativePrivacyCover,
        isFalse,
      );
    },
  );

  test(
    'uses the injected connectivity service',
    () async {
      final runtime = createTestBoorusamaRuntime(
        connectivityService: const TestConnectivityService(
          result: ConnectivityResult.none,
        ),
      );
      final container = _createRuntimeContainer(runtime);

      expect(
        await container.read(currentConnectivityProvider.future),
        [ConnectivityResult.none],
      );
    },
  );

  testWidgets(
    'restarting the app scope keeps runtime dependencies available',
    (tester) async {
      final runtime = createTestBoorusamaRuntime(
        platform: AppPlatform.android,
      );

      await tester.pumpWidget(
        BoorusamaAppScope(
          runtime: runtime,
          child: const _RestartProbe(),
        ),
      );

      expect(find.text('android'), findsOneWidget);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('android'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

ProviderContainer _createRuntimeContainer(BoorusamaRuntime runtime) {
  final container = createContainer(
    overrides: buildBoorusamaOverrides(
      runtime,
      RebootData(
        config: runtime.initialState.initialConfig,
        configs: runtime.initialState.configs,
        settings: runtime.initialState.settings,
      ),
    ),
  );
  return container;
}

class _RestartProbe extends ConsumerWidget {
  const _RestartProbe();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final platform = ref.watch(appPlatformProvider);
    return MaterialApp(
      home: Column(
        children: [
          Text(platform.wireName),
          ElevatedButton(
            onPressed: () => Reboot.start(context, null),
            child: const Text('Restart'),
          ),
        ],
      ),
    );
  }
}
