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

  group('Settings app lock fields', () {
    test('default settings keep app lock disabled', () {
      const settings = Settings.defaultSettings;

      expect(settings.appLockType, AppLockType.none);
      expect(settings.appLockTimeoutSeconds, 0);
      expect(settings.hideAppPreviewWhenBackgrounded, isTrue);
    });

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

class _TrackingPinCredentialRepository extends PinCredentialRepository {
  _TrackingPinCredentialRepository() : super(Completer<Box<String>>().future);

  var cleared = false;

  @override
  Future<void> clearPin() async => cleared = true;

  @override
  Future<bool> verifyPin(String pin) async => pin == '1234';
}
