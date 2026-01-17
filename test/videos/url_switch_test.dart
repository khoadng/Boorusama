import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:video_player/video_player.dart';

import 'package:boorusama/core/videos/engines/src/engines/video_player_booru_player.dart';
import 'package:boorusama/core/videos/engines/types.dart';
import 'package:boorusama/core/videos/lock/types.dart';

class MockVideoPlayerController extends Mock implements VideoPlayerController {}

class MockWakelock extends Mock implements Wakelock {}

// ignore: avoid_implementing_value_types
class FakeVideoPlayerValue extends Fake implements VideoPlayerValue {
  @override
  bool get isInitialized => true;

  @override
  bool get isPlaying => false;

  @override
  bool get isBuffering => false;

  @override
  Duration get position => Duration.zero;

  @override
  Duration get duration => const Duration(seconds: 10);

  @override
  double get aspectRatio => 16 / 9;

  @override
  Size get size => const Size(1920, 1080);
}

const _testSource = StreamingVideoSource('https://example.com/video.mp4');
const _testSource2 = StreamingVideoSource('https://example.com/video2.mp4');

void main() {
  late MockWakelock mockWakelock;

  setUpAll(() {
    registerFallbackValue(_testSource);
    registerFallbackValue(const VideoConfig());
  });

  setUp(() {
    mockWakelock = MockWakelock();
    when(() => mockWakelock.enable()).thenAnswer((_) {});
    when(() => mockWakelock.disable()).thenAnswer((_) {});
  });

  MockVideoPlayerController createMockController({
    Duration disposalDelay = Duration.zero,
    Completer<void>? disposalCompleter,
  }) {
    final controller = MockVideoPlayerController();
    final value = FakeVideoPlayerValue();

    when(() => controller.value).thenReturn(value);
    when(() => controller.initialize()).thenAnswer((_) async {});
    when(() => controller.addListener(any())).thenReturn(null);
    when(() => controller.removeListener(any())).thenReturn(null);
    when(() => controller.dispose()).thenAnswer((_) async {
      if (disposalDelay > Duration.zero) {
        await Future.delayed(disposalDelay);
      }
      disposalCompleter?.complete();
    });

    return controller;
  }

  group('VideoPlayerBooruPlayer switchUrl disposal', () {
    test('old controller disposal completes before switchUrl returns', () async {
      // This test verifies that switchUrl waits for old controller disposal
      //
      // EXPECTED BEHAVIOR: switchUrl should not return until old controller
      // is fully disposed to prevent native resource conflicts
      //
      // CURRENT BUG: Uses unawaited((() => oldController.dispose())())
      // which returns immediately without waiting

      final oldControllerDisposalCompleter = Completer<void>();

      final oldController = createMockController(
        disposalDelay: const Duration(milliseconds: 50),
        disposalCompleter: oldControllerDisposalCompleter,
      );
      final newController = createMockController();

      var controllerIndex = 0;
      final controllers = [oldController, newController];

      final player = VideoPlayerBooruPlayer(
        wakelock: mockWakelock,
        controllerFactory: (source, config) => controllers[controllerIndex++],
        skipFvpInit: true,
      );

      // Initialize with first controller
      await player.initialize(_testSource);
      expect(controllerIndex, 1);

      // Switch URL - this should wait for old controller disposal
      await player.switchUrl(_testSource2);

      // After switchUrl returns, old controller should be disposed
      expect(
        oldControllerDisposalCompleter.isCompleted,
        isTrue,
        reason:
            'switchUrl should wait for old controller disposal to complete. '
            'Current implementation uses unawaited() which causes race conditions '
            'with native resources (pthread_mutex crash).',
      );
    });

    test('rapid URL switching waits for each disposal', () async {
      // Simulates rapid swiping through posts
      final disposalCompleters = <Completer<void>>[];

      final controllers = List.generate(4, (i) {
        final completer = Completer<void>();
        disposalCompleters.add(completer);
        return createMockController(
          disposalDelay: Duration(milliseconds: 20 * (i + 1)),
          disposalCompleter: completer,
        );
      });

      var controllerIndex = 0;
      final player = VideoPlayerBooruPlayer(
        wakelock: mockWakelock,
        controllerFactory: (source, config) => controllers[controllerIndex++],
        skipFvpInit: true,
      );

      // Initialize
      await player.initialize(_testSource);

      // Rapid URL switches
      for (var i = 0; i < 3; i++) {
        await player.switchUrl(
          StreamingVideoSource('https://example.com/video$i.mp4'),
        );
        // After each switchUrl, the previous controller should be disposed
        expect(
          disposalCompleters[i].isCompleted,
          isTrue,
          reason: 'Controller $i should be disposed after switchUrl $i',
        );
      }

      // All first 3 controllers should be disposed (index 0, 1, 2)
      // Controller 3 is the current one, not disposed yet
      final completedCount = disposalCompleters
          .take(3)
          .where((c) => c.isCompleted)
          .length;
      expect(
        completedCount,
        3,
        reason: 'All 3 old controllers should be disposed',
      );
    });

    test('no concurrent disposal operations', () async {
      // Verify that disposal operations don't overlap
      var activeDisposals = 0;
      var maxConcurrentDisposals = 0;

      final controllers = List.generate(4, (i) {
        final controller = MockVideoPlayerController();
        final value = FakeVideoPlayerValue();

        when(() => controller.value).thenReturn(value);
        when(() => controller.initialize()).thenAnswer((_) async {});
        when(() => controller.addListener(any())).thenReturn(null);
        when(() => controller.removeListener(any())).thenReturn(null);
        when(() => controller.dispose()).thenAnswer((_) async {
          activeDisposals++;
          maxConcurrentDisposals = maxConcurrentDisposals > activeDisposals
              ? maxConcurrentDisposals
              : activeDisposals;
          await Future.delayed(const Duration(milliseconds: 30));
          activeDisposals--;
        });

        return controller;
      });

      var controllerIndex = 0;
      final player = VideoPlayerBooruPlayer(
        wakelock: mockWakelock,
        controllerFactory: (source, config) => controllers[controllerIndex++],
        skipFvpInit: true,
      );

      await player.initialize(_testSource);

      // Rapid switches
      for (var i = 0; i < 3; i++) {
        await player.switchUrl(
          StreamingVideoSource('https://example.com/video$i.mp4'),
        );
      }

      // Wait for any pending disposals
      await Future.delayed(const Duration(milliseconds: 150));

      // With proper sequential disposal, max concurrent should be 1
      // THIS WILL FAIL with current implementation (will be > 1)
      expect(
        maxConcurrentDisposals,
        1,
        reason:
            'Only one disposal should be active at a time. '
            'Got $maxConcurrentDisposals concurrent disposals.',
      );
    });
  });
}
