// Dart imports:
import 'dart:convert';

// Flutter imports:
import 'package:flutter/widgets.dart';

// Package imports:
import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_symbols_icons/symbols.dart';

// Project imports:
import 'package:boorusama/core/settings/src/pages/app_lock_settings_page.dart';
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/foundation/applock/applock.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';

import '../support/boorusama_test_runtime.dart';
import 'support/fake_booru_backend.dart';
import 'support/headless_app_harness.dart';

void main() {
  testWidgets('locks and unlocks the app through the headless PIN flow', (
    tester,
  ) async {
    final pinStore = MemoryPinCredentialStore();
    final pinFactory = _FastPinCredentialRepositoryFactory(pinStore);
    await pinFactory.repository.setPin('1234');
    final backend = FakeBooruBackend();

    final harness = HeadlessAppHarness(
      runtime: backend.createRuntime(
        settings: Settings.defaultSettings.copyWith(
          appLockType: AppLockType.pin,
          appLockTimeoutSeconds: 0,
        ),
        pinCredentialRepositoryFactory: pinFactory,
      ),
    );
    addTearDown(() => harness.teardown(tester));

    await harness.pump(tester);
    await harness.pumpUntilFound(
      tester,
      find.text('Unlock Boorusama'),
    );

    expect(find.text('Boorusama is locked'), findsNothing);
    await _enterPin(tester, '4321');
    expect(find.text('Incorrect PIN'), findsOneWidget);

    await tester.pump(const Duration(seconds: 1));
    await _enterPin(tester, '1234');
    await harness.settle(tester);
    expect(find.text('Unlock Boorusama'), findsNothing);
    expect(await pinStore.get('pin_credential'), isNotNull);
  });

  testWidgets('configures, uses, and disables PIN locking through the UI', (
    tester,
  ) async {
    final pinStore = MemoryPinCredentialStore();
    final pinFactory = _FastPinCredentialRepositoryFactory(pinStore);
    final backend = FakeBooruBackend();
    final harness = HeadlessAppHarness(
      booruBackend: backend,
      runtime: backend.createRuntime(
        settings: Settings.defaultSettings.copyWith(
          appLockTimeoutSeconds: 0,
        ),
        pinCredentialRepositoryFactory: pinFactory,
      ),
    );
    addTearDown(() => harness.teardown(tester));

    await harness.pump(tester);
    await harness.settle(tester);
    await _openSettings(tester, harness);

    final privacy = find.text('Privacy');
    if (privacy.evaluate().isEmpty) {
      final navigationList = find.byKey(
        const ValueKey('settings-compact-index-list'),
      );
      await tester.scrollUntilVisible(
        privacy,
        200,
        scrollable: find.descendant(
          of: navigationList,
          matching: find.byType(Scrollable),
        ),
      );
    }
    await tester.tap(privacy);
    await tester.pump();
    await harness.settle(tester);
    await tester.tap(find.text('App lock'));
    await tester.pump();
    await harness.settle(tester);

    await tester.tap(find.byIcon(Symbols.keyboard_arrow_down).first);
    await tester.pump();
    await harness.settle(tester);
    await tester.tap(find.text('PIN').last);
    await tester.pump();
    await _enterPin(tester, '1234');
    await _enterPin(tester, '1234');
    await harness.settle(tester);

    final settingsRepository =
        harness.runtime.dependencies.settingsRepository
            as MemorySettingsRepository;
    expect(pinStore.get('pin_credential'), completion(isNotNull));
    expect(settingsRepository.savedSettings.last.appLockType, AppLockType.pin);
    expect(find.byType(AppLockSettingsPage), findsOneWidget);

    WidgetsBinding.instance.handleAppLifecycleStateChanged(
      AppLifecycleState.inactive,
    );
    await tester.pump();
    await harness.pumpUntilFound(tester, find.text('Unlock Boorusama'));

    await _enterPin(tester, '4321');
    expect(find.text('Incorrect PIN'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await _enterPin(tester, '1234');
    await harness.settle(tester);
    expect(find.text('Unlock Boorusama'), findsNothing);

    await tester.tap(find.byIcon(Symbols.keyboard_arrow_down).first);
    await tester.pump();
    await harness.settle(tester);
    await tester.tap(find.text('Off').last);
    await tester.pump();
    await _enterPin(tester, '1234');
    await harness.settle(tester);

    expect(settingsRepository.savedSettings.last.appLockType, AppLockType.none);
    expect(await pinStore.get('pin_credential'), isNull);
  });
}

Future<void> _openSettings(
  WidgetTester tester,
  HeadlessAppHarness harness,
) async {
  final settingsIcon = find.byIcon(Symbols.settings);
  if (settingsIcon.evaluate().isNotEmpty) {
    await tester.tap(settingsIcon.last);
  } else {
    await tester.tap(find.byIcon(Symbols.menu).first);
    await tester.pump();
    await harness.settle(tester);
    await tester.tap(find.text('Settings').last);
  }
  await tester.pump();
  await harness.settle(tester);
}

final class _FastPinCredentialRepositoryFactory
    implements PinCredentialRepositoryFactory {
  _FastPinCredentialRepositoryFactory(MemoryPinCredentialStore store)
    : _store = store,
      repository = PinCredentialRepository.fromStore(
        store,
        keyDeriver: const _FastPinKeyDeriver(),
      );

  final MemoryPinCredentialStore _store;
  final PinCredentialRepository repository;

  @override
  PinCredentialRepository create() => PinCredentialRepository.fromStore(
    _store,
    keyDeriver: const _FastPinKeyDeriver(),
  );

  @override
  Future<void> dispose(PinCredentialRepository repository) =>
      repository.close();
}

final class _FastPinKeyDeriver extends PinKeyDeriver {
  const _FastPinKeyDeriver();

  @override
  Future<String> derive({
    required String pin,
    required String salt,
    required int iterations,
  }) async => sha256.convert(utf8.encode('$pin:$salt')).toString();
}

Future<void> _enterPin(WidgetTester tester, String pin) async {
  for (final digit in pin.split('')) {
    await tester.tap(find.text(digit).last);
    await tester.pump();
  }
  await tester.pump();
}
