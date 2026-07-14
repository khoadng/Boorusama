// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce/hive.dart';
import 'package:i18n/i18n.dart';

// Project imports:
import 'package:boorusama/foundation/applock/applock.dart';
import 'package:boorusama/foundation/pincode/pincode.dart';

void main() {
  setUpAll(() async {
    await ensureI18nInitialized('en-US');
  });

  group('AppLock protected content', () {
    late Directory tempDir;
    late Box<String> box;
    late PinCredentialRepository repository;

    setUp(() async {
      tempDir = await Directory.systemTemp.createTemp(
        'app_lock_widget_test_',
      );
      box = await Hive.openBox<String>(
        'app_lock_widget_credentials_test',
        path: tempDir.path,
      );
      repository = PinCredentialRepository(Future.value(box));
    });

    tearDown(() async {
      await box.close();
      await tempDir.delete(recursive: true);
    });

    testWidgets('does not build child before initial PIN unlock', (
      tester,
    ) async {
      var childBuilds = 0;

      await tester.pumpWidget(
        _AppLockTestApp(
          repository: repository,
          type: AppLockType.pin,
          child: Builder(
            builder: (context) {
              childBuilds++;
              return const Text('Protected content');
            },
          ),
        ),
      );
      await tester.pump();

      expect(childBuilds, 0);
      expect(find.text('Protected content'), findsNothing);
    });

    testWidgets('builds child when app lock is disabled', (tester) async {
      var childBuilds = 0;

      await tester.pumpWidget(
        _AppLockTestApp(
          repository: repository,
          type: AppLockType.none,
          child: Builder(
            builder: (context) {
              childBuilds++;
              return const Text('Protected content');
            },
          ),
        ),
      );

      expect(childBuilds, 1);
      expect(find.text('Protected content'), findsOneWidget);
    });
  });
}

class _AppLockTestApp extends StatelessWidget {
  const _AppLockTestApp({
    required this.repository,
    required this.type,
    required this.child,
  });

  final PinCredentialRepository repository;
  final AppLockType type;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return BooruLocalization(
      child: ProviderScope(
        overrides: [
          pinCredentialRepositoryProvider.overrideWithValue(repository),
        ],
        child: MaterialApp(
          home: AppLock(
            type: type,
            timeout: Duration.zero,
            child: child,
          ),
        ),
      ),
    );
  }
}
