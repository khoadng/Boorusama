// Package imports:
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/foundation/applock/src/app_lock_session.dart';
import 'package:boorusama/foundation/applock/src/app_lock_type.dart';

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

    test('successful unlock is not reversed by a pending resumed event', () {
      final session = newSession();

      session.didChangeAppLifecycleState(AppLifecycleState.inactive);
      session.unlock();
      session.didChangeAppLifecycleState(AppLifecycleState.resumed);

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
}
