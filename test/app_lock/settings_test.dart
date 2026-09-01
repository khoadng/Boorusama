// Dart imports:
import 'dart:async';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:i18n/i18n.dart';
import 'package:kurumi/kurumi.dart';

// Project imports:
import 'package:boorusama/core/settings/src/data/providers.dart';
import 'package:boorusama/core/settings/src/pages/app_lock_settings_page.dart';
import 'package:boorusama/core/settings/src/providers/settings_notifier.dart';
import 'package:boorusama/core/settings/src/types/settings.dart';
import 'package:boorusama/core/settings/src/types/settings_repository.dart';
import 'package:boorusama/foundation/applock/src/app_lock_type.dart';
import 'package:boorusama/foundation/applock/src/app_lock_capabilities.dart';
import 'package:boorusama/foundation/applock/src/biometrics.dart';
import 'package:boorusama/foundation/platform.dart';
import 'package:boorusama/foundation/pincode/src/pin_credential.dart';

void main() {
  setUpAll(() async {
    await ensureI18nInitialized('en-US');
  });

  testWidgets('failed lock-type save preserves the existing PIN', (
    tester,
  ) async {
    final credentials = _TrackingPinCredentialRepository();

    final initialSettings = Settings.defaultSettings.copyWith(
      appLockType: AppLockType.pin,
    );

    await tester.pumpWidget(
      BooruLocalization(
        child: ProviderScope(
          overrides: [
            settingsRepoProvider.overrideWithValue(
              _RejectingSettingsRepository(),
            ),
            settingsNotifierProvider.overrideWith(
              () => SettingsNotifier(initialSettings),
            ),
            pinCredentialRepositoryProvider.overrideWithValue(credentials),
          ],
          child: const MaterialApp(home: AppLockSettingsPage()),
        ),
      ),
    );
    await tester.pump();

    final lockTypeDropdown = find.byType(
      KurumiOptionDropDownButton<AppLockType>,
    );
    tester
        .widget<KurumiOptionDropDownButton<AppLockType>>(lockTypeDropdown)
        .onChanged(AppLockType.none);
    await tester.pump(const Duration(milliseconds: 300));

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit).last);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(credentials.cleared, isFalse);
  });

  testWidgets('Linux does not offer unsupported device authentication', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepoProvider.overrideWithValue(
            _RejectingSettingsRepository(),
          ),
          settingsNotifierProvider.overrideWith(
            () => SettingsNotifier(Settings.defaultSettings),
          ),
          appLockCapabilitiesProvider.overrideWithValue(
            AppLockCapabilities.forPlatform(AppPlatform.linux),
          ),
          pinCredentialRepositoryProvider.overrideWithValue(
            _TrackingPinCredentialRepository(),
          ),
        ],
        child: const BooruLocalization(
          child: MaterialApp(home: AppLockSettingsPage()),
        ),
      ),
    );
    await tester.pump();

    final lockTypeDropdown = tester
        .widget<KurumiOptionDropDownButton<AppLockType>>(
          find.byType(KurumiOptionDropDownButton<AppLockType>),
        );

    expect(
      lockTypeDropdown.items.map((item) => item.value),
      [AppLockType.none, AppLockType.pin],
    );
  });

  testWidgets('device authentication removes the previous app PIN', (
    tester,
  ) async {
    final credentials = _TrackingPinCredentialRepository();
    final initialSettings = Settings.defaultSettings.copyWith(
      appLockType: AppLockType.pin,
    );

    await tester.pumpWidget(
      BooruLocalization(
        child: ProviderScope(
          overrides: [
            settingsNotifierProvider.overrideWith(
              () => _SuccessfulSettingsNotifier(initialSettings),
            ),
            pinCredentialRepositoryProvider.overrideWithValue(credentials),
            canUseBiometricLockProvider.overrideWith((ref) => true),
          ],
          child: const MaterialApp(home: AppLockSettingsPage()),
        ),
      ),
    );
    await tester.pump();

    final lockTypeDropdown = find.byType(
      KurumiOptionDropDownButton<AppLockType>,
    );
    tester
        .widget<KurumiOptionDropDownButton<AppLockType>>(lockTypeDropdown)
        .onChanged(AppLockType.biometrics);
    await tester.pump(const Duration(milliseconds: 300));

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit).last);
      await tester.pump(const Duration(milliseconds: 50));
    }
    await tester.pump(const Duration(milliseconds: 300));

    expect(credentials.cleared, isTrue);
  });

  testWidgets('failed PIN enable removes the unused new credential', (
    tester,
  ) async {
    final credentials = _TrackingPinCredentialRepository(hasCredential: false);

    await tester.pumpWidget(
      BooruLocalization(
        child: ProviderScope(
          overrides: [
            settingsRepoProvider.overrideWithValue(
              _RejectingSettingsRepository(),
            ),
            settingsNotifierProvider.overrideWith(
              () => SettingsNotifier(Settings.defaultSettings),
            ),
            pinCredentialRepositoryProvider.overrideWithValue(credentials),
          ],
          child: const MaterialApp(home: AppLockSettingsPage()),
        ),
      ),
    );
    await tester.pump();

    tester
        .widget<KurumiOptionDropDownButton<AppLockType>>(
          find.byType(KurumiOptionDropDownButton<AppLockType>),
        )
        .onChanged(AppLockType.pin);
    await tester.pumpAndSettle();
    for (final pin in ['1234', '1234']) {
      for (final digit in pin.split('')) {
        await tester.tap(find.text(digit).last);
        await tester.pump();
      }
    }
    await tester.pumpAndSettle();

    expect(credentials.cleared, isTrue);
    expect(credentials.hasCredential, isFalse);
  });

  group('Settings app lock fields', () {
    test('legacy settings JSON uses app lock defaults', () {
      final json = Settings.defaultSettings.toJson()
        ..remove('appLockTimeoutSeconds')
        ..remove('hideAppPreviewWhenBackgrounded');

      final settings = Settings.fromJson(json);

      expect(settings.appLockTimeoutSeconds, 0);
      expect(settings.hideAppPreviewWhenBackgrounded, isTrue);
    });
  });
}

class _RejectingSettingsRepository implements SettingsRepository {
  @override
  SettingsOrError load() => throw UnimplementedError();

  @override
  Future<bool> save(Settings setting) async => false;
}

class _SuccessfulSettingsNotifier extends SettingsNotifier {
  _SuccessfulSettingsNotifier(super.initialSettings);

  @override
  Future<bool> updateWith(Settings Function(Settings) selector) async {
    state = selector(state);
    return true;
  }
}

class _TrackingPinCredentialRepository extends PinCredentialRepository {
  _TrackingPinCredentialRepository({this.hasCredential = true})
    : super(Completer<Box<String>>().future);

  bool hasCredential;
  var cleared = false;

  @override
  Future<bool> hasPin() async => hasCredential;

  @override
  Future<void> setPin(String pin) async {
    hasCredential = true;
  }

  @override
  Future<void> clearPin() async {
    cleared = true;
    hasCredential = false;
  }

  @override
  Future<bool> verifyPin(String pin) async => pin == '1234';
}
