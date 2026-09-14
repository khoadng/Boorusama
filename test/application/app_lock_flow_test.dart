import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

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
    addTearDown(harness.dispose);

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
