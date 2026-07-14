// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';

// Project imports:
import 'package:boorusama/core/settings/types.dart';
import 'package:boorusama/foundation/applock/applock.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';

void main() {
  group('AppLockSession', () {
    late DateTime now;

    AppLockSession newSession({
      AppLockType type = AppLockType.pin,
      Duration timeout = Duration.zero,
      bool hideAppPreviewWhenBackgrounded = true,
    }) {
      return AppLockSession(
        config: AppLockSessionConfig(
          type: type,
          timeout: timeout,
          hideAppPreviewWhenBackgrounded: hideAppPreviewWhenBackgrounded,
        ),
        now: () => now,
      );
    }

    setUp(() {
      now = DateTime(2026);
    });

    test('starts locked when app lock is enabled', () {
      expect(newSession().locked, isTrue);
      expect(newSession(type: AppLockType.biometrics).locked, isTrue);
      expect(newSession(type: AppLockType.none).locked, isFalse);
    });

    test('unlock clears locked state and privacy cover', () {
      final session = newSession();

      session.didChangeAppLifecycleState(AppLifecycleState.inactive);
      session.unlock();

      expect(session.locked, isFalse);
      expect(session.privacyCoverVisible, isFalse);
    });

    test(
      'backgrounding shows privacy cover without immediate lock before timeout',
      () {
        final session = newSession(timeout: const Duration(minutes: 5));
        session.unlock();

        session.didChangeAppLifecycleState(AppLifecycleState.inactive);

        expect(session.locked, isFalse);
        expect(session.privacyCoverVisible, isTrue);
      },
    );

    test('backgrounding locks immediately when timeout is zero', () {
      final session = newSession();
      session.unlock();

      session.didChangeAppLifecycleState(AppLifecycleState.paused);

      expect(session.locked, isTrue);
      expect(session.privacyCoverVisible, isTrue);
    });

    test('resuming before timeout keeps app unlocked and hides cover', () {
      final session = newSession(timeout: const Duration(minutes: 5));
      session.unlock();

      session.didChangeAppLifecycleState(AppLifecycleState.paused);
      now = now.add(const Duration(minutes: 4));
      session.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(session.locked, isFalse);
      expect(session.privacyCoverVisible, isFalse);
    });

    test('resuming after timeout locks app and hides cover', () {
      final session = newSession(timeout: const Duration(minutes: 5));
      session.unlock();

      session.didChangeAppLifecycleState(AppLifecycleState.hidden);
      now = now.add(const Duration(minutes: 5));
      session.didChangeAppLifecycleState(AppLifecycleState.resumed);

      expect(session.locked, isTrue);
      expect(session.privacyCoverVisible, isFalse);
    });

    test('does not show privacy cover when preview hiding is disabled', () {
      final session = newSession(
        timeout: const Duration(minutes: 5),
        hideAppPreviewWhenBackgrounded: false,
      );
      session.unlock();

      session.didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(session.locked, isFalse);
      expect(session.privacyCoverVisible, isFalse);
    });

    test('shows privacy cover when app lock is disabled', () {
      final session = newSession(type: AppLockType.none);

      session.didChangeAppLifecycleState(AppLifecycleState.inactive);

      expect(session.locked, isFalse);
      expect(session.privacyCoverVisible, isTrue);
    });

    test(
      'does not show privacy cover when app lock and preview hiding are disabled',
      () {
        final session = newSession(
          type: AppLockType.none,
          hideAppPreviewWhenBackgrounded: false,
        );

        session.didChangeAppLifecycleState(AppLifecycleState.inactive);

        expect(session.locked, isFalse);
        expect(session.privacyCoverVisible, isFalse);
      },
    );

    test('turning preview hiding off clears an active privacy cover', () {
      final session = newSession(timeout: const Duration(minutes: 5));
      session.unlock();
      session.didChangeAppLifecycleState(AppLifecycleState.inactive);

      session.updateConfig(
        const AppLockSessionConfig(
          type: AppLockType.pin,
          timeout: Duration(minutes: 5),
          hideAppPreviewWhenBackgrounded: false,
        ),
      );

      expect(session.locked, isFalse);
      expect(session.privacyCoverVisible, isFalse);
    });

    test(
      'enabling lock from off does not immediately lock current session',
      () {
        final session = newSession(type: AppLockType.none);

        session.updateConfig(
          const AppLockSessionConfig(
            type: AppLockType.pin,
            timeout: Duration.zero,
            hideAppPreviewWhenBackgrounded: true,
          ),
        );

        expect(session.locked, isFalse);
      },
    );

    test('changing active lock type locks current session', () {
      final session = newSession();
      session.unlock();

      session.updateConfig(
        const AppLockSessionConfig(
          type: AppLockType.biometrics,
          timeout: Duration.zero,
          hideAppPreviewWhenBackgrounded: true,
        ),
      );

      expect(session.locked, isTrue);
    });

    test(
      'disabling lock clears current lock without disabling preview cover',
      () {
        final session = newSession(timeout: const Duration(minutes: 5));
        session.unlock();
        session.didChangeAppLifecycleState(AppLifecycleState.inactive);

        session.updateConfig(
          const AppLockSessionConfig(
            type: AppLockType.none,
            timeout: Duration.zero,
            hideAppPreviewWhenBackgrounded: true,
          ),
        );

        expect(session.locked, isFalse);
        expect(session.privacyCoverVisible, isTrue);
      },
    );
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

  group('PinCredentialRepository', () {
    late Directory tempDir;
    late Box<String> box;
    late PinCredentialRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp('app_lock_test_');
      box = await Hive.openBox<String>(
        'app_lock_credentials_test',
        path: tempDir.path,
      );
      repository = PinCredentialRepository(Future.value(box));
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    test('stores and verifies PIN without storing raw PIN', () async {
      await repository.setPin('1234');

      expect(await repository.hasPin(), isTrue);
      expect(await repository.verifyPin('1234'), isTrue);
      expect(await repository.verifyPin('4321'), isFalse);

      final credential = await repository.getPinCredential();
      expect(credential, isNotNull);
      expect(credential!.verifier, isNot(contains('1234')));
    });

    test('clears PIN credential', () async {
      await repository.setPin('1234');
      await repository.clearPin();

      expect(await repository.hasPin(), isFalse);
      expect(await repository.verifyPin('1234'), isFalse);
    });
  });
}
