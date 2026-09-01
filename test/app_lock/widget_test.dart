// Dart imports:
import 'dart:async';
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    testWidgets('missing PIN credential fails closed', (tester) async {
      await tester.pumpWidget(
        _AppLockTestApp(
          repository: _MissingPinRepository(),
          type: AppLockType.pin,
          child: const Text('Protected content'),
        ),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Set app PIN'), findsNothing);
      expect(find.text('Boorusama is locked'), findsOneWidget);
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

    testWidgets('biometric lock surface is vertically centered', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _AppLockTestApp(
          repository: repository,
          type: AppLockType.biometrics,
          canUseBiometrics: true,
          child: const Text('Protected content'),
        ),
      );
      await tester.pumpAndSettle();

      final title = tester.getRect(
        find.text('Please authenticate to use the app'),
      );
      final unlockButton = tester.getRect(find.byType(IconButton));
      final contentCenter = (title.top + unlockButton.bottom) / 2;

      expect(contentCenter, closeTo(404, 1));
    });

    testWidgets('PIN surface remains usable at short viewport heights', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(800, 400);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        _AppLockTestApp(
          repository: _ExistingPinRepository(),
          type: AppLockType.pin,
          child: const Text('Protected content'),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.text('1'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });
  });

  testWidgets('PIN mismatch does not move the keypad', (tester) async {
    await tester.pumpWidget(
      BooruLocalization(
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: PinSetupPanel(
                title: 'Set PIN',
                onSubmit: (_) async {},
              ),
            ),
          ),
        ),
      ),
    );

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }

    final keypadTopBeforeMismatch = tester.getTopLeft(find.text('1')).dy;

    for (final digit in ['4', '3', '2', '1']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }

    expect(find.text('PINs do not match.'), findsOneWidget);
    expect(
      tester.getTopLeft(find.text('1')).dy,
      keypadTopBeforeMismatch,
    );

    await tester.tap(find.text('1'));
    await tester.pump();

    expect(find.text('PINs do not match.'), findsNothing);
    expect(
      tester.getTopLeft(find.text('1')).dy,
      keypadTopBeforeMismatch,
    );
  });

  testWidgets('PIN panels accept a physical keyboard', (tester) async {
    await _pumpPinSetup(tester, const Size(1200, 800));

    for (final key in [
      LogicalKeyboardKey.digit1,
      LogicalKeyboardKey.digit2,
      LogicalKeyboardKey.digit3,
    ]) {
      await tester.sendKeyEvent(key);
      await tester.pump();
    }
    await tester.sendKeyEvent(LogicalKeyboardKey.backspace);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit3);
    await tester.sendKeyEvent(LogicalKeyboardKey.digit4);
    await tester.pump();

    expect(find.text('Confirm PIN'), findsOneWidget);
  });

  testWidgets('PIN verification loading does not move the keypad', (
    tester,
  ) async {
    final verification = Completer<bool>();
    var unlocked = false;

    await tester.pumpWidget(
      BooruLocalization(
        child: MaterialApp(
          home: Scaffold(
            body: Align(
              child: PinUnlockPanel(
                title: 'Unlock',
                onSubmit: (_) => verification.future,
                onUnlocked: () => unlocked = true,
              ),
            ),
          ),
        ),
      ),
    );

    final keypadTop = tester.getTopLeft(find.text('1')).dy;

    for (final digit in ['1', '2', '3', '4']) {
      await tester.tap(find.text(digit));
      await tester.pump();
    }

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(tester.getTopLeft(find.text('1')).dy, keypadTop);

    verification.complete(true);
    await tester.pump();
    await tester.pump();

    expect(unlocked, isTrue);
    expect(find.byType(CircularProgressIndicator), findsNothing);
    expect(tester.getTopLeft(find.text('1')).dy, keypadTop);
  });

  group('responsive PIN layout', () {
    testWidgets('uses a stacked layout on a phone portrait', (tester) async {
      await _pumpPinSetup(tester, const Size(400, 800));

      final title = tester.getRect(find.text('Create PIN'));
      final firstDigit = tester.getRect(find.text('1'));

      expect(title.center.dx, closeTo(200, 1));
      expect(title.bottom, lessThan(firstDigit.top));
    });

    testWidgets('uses a stacked layout on a portrait tablet', (tester) async {
      await _pumpPinSetup(tester, const Size(700, 900));

      final title = tester.getRect(find.text('Create PIN'));
      final firstDigit = tester.getRect(find.text('1'));

      expect(title.center.dx, closeTo(350, 1));
      expect(title.bottom, lessThan(firstDigit.top));
    });

    testWidgets('uses two columns on a phone landscape', (tester) async {
      await _pumpPinSetup(tester, const Size(800, 400));

      final title = tester.getRect(find.text('Create PIN'));
      final firstDigit = tester.getRect(find.text('1'));

      expect(title.center.dx, lessThan(firstDigit.center.dx));
    });

    testWidgets('uses two columns on a wide desktop', (tester) async {
      await _pumpPinSetup(tester, const Size(1200, 800));

      final title = tester.getRect(find.text('Create PIN'));
      final firstDigit = tester.getRect(find.text('1'));

      expect(title.center.dx, lessThan(firstDigit.center.dx));
    });
  });

  testWidgets('PIN dialog back button stays in the viewport corner', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pinCredentialRepositoryProvider.overrideWithValue(
            _ExistingPinRepository(),
          ),
        ],
        child: const BooruLocalization(
          child: MaterialApp(home: _PinDialogLauncher()),
        ),
      ),
    );
    await tester.tap(find.text('Open PIN dialog'));
    await tester.pumpAndSettle();

    final backButton = tester.getRect(find.byType(BackButton));

    expect(backButton.left, lessThanOrEqualTo(16));
    expect(backButton.top, lessThanOrEqualTo(16));

    tester.view.physicalSize = const Size(400, 800);
    await tester.pumpAndSettle();

    expect(tester.getRect(find.byType(BackButton)).topLeft, backButton.topLeft);
  });
}

Future<void> _pumpPinSetup(WidgetTester tester, Size size) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    BooruLocalization(
      child: MaterialApp(
        home: Scaffold(
          body: Align(
            child: PinSetupPanel(
              title: 'Set PIN',
              onSubmit: (_) async {},
            ),
          ),
        ),
      ),
    ),
  );
}

class _PinDialogLauncher extends ConsumerWidget {
  const _PinDialogLauncher();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Center(
        child: FilledButton(
          onPressed: () => showPinSetupDialog(context, ref),
          child: const Text('Open PIN dialog'),
        ),
      ),
    );
  }
}

class _ExistingPinRepository extends PinCredentialRepository {
  _ExistingPinRepository() : super(Completer<Box<String>>().future);

  @override
  Future<bool> hasPin() async => true;
}

class _MissingPinRepository extends PinCredentialRepository {
  _MissingPinRepository() : super(Completer<Box<String>>().future);

  @override
  Future<bool> hasPin() async => false;
}

class _AppLockTestApp extends StatelessWidget {
  const _AppLockTestApp({
    required this.repository,
    required this.type,
    required this.child,
    this.canUseBiometrics,
  });

  final PinCredentialRepository repository;
  final AppLockType type;
  final Widget child;
  final bool? canUseBiometrics;

  @override
  Widget build(BuildContext context) {
    return BooruLocalization(
      child: ProviderScope(
        overrides: [
          pinCredentialRepositoryProvider.overrideWithValue(repository),
          if (canUseBiometrics case final canUseBiometrics?)
            canUseBiometricLockProvider.overrideWith(
              (ref) => canUseBiometrics,
            ),
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
