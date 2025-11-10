// Dart imports:
import 'dart:async';

// Package imports:
import 'package:flutter_test/flutter_test.dart';

// Project imports:
import 'package:boorusama/core/posts/slideshow/types.dart';

class _FakeTimer implements Timer {
  _FakeTimer(this.callback);

  final dynamic Function() callback;

  @override
  void cancel() {}

  @override
  bool get isActive => true;

  @override
  int get tick => 0;
}

class _TimerController {
  final _timers = <_FakeTimer>[];
  final _durations = <Duration>[];

  Timer createTimer(Duration duration, dynamic Function() callback) {
    final timer = _FakeTimer(callback);
    _timers.add(timer);
    _durations.add(duration);
    return timer;
  }

  Future<void> triggerNext() async {
    if (_timers.isNotEmpty) {
      await _timers.first.callback();
    }
  }

  void clearHistory() {
    _timers.clear();
    _durations.clear();
  }

  Duration? get lastDuration => _durations.isNotEmpty ? _durations.last : null;
}

void main() {
  group('SlideshowRunning', () {
    test('initial factory positions correctly in random sequence', () {
      final cases = [
        (startPage: 0, totalPages: 5),
        (startPage: 2, totalPages: 5),
        (startPage: 4, totalPages: 5),
      ];

      for (final c in cases) {
        final state = SlideshowRunning.initial(
          startPage: c.startPage,
          totalPages: c.totalPages,
          direction: SlideshowDirection.random,
        );

        expect(state.currentPage, c.startPage);
        expect(state.randomSequence, isNotNull);
        expect(state.randomSequence!.length, c.totalPages);
        expect(state.randomSequence![state.randomIndex], c.startPage);
      }
    });

    test('skips animation in random mode', () {
      final state = SlideshowRunning.initial(
        startPage: 0,
        totalPages: 5,
        direction: SlideshowDirection.random,
      );

      expect(
        state.shouldSkipAnimation(const SlideshowOptions()),
        true,
      );
    });
  });

  group('SlideshowController', () {
    late _TimerController timerController;
    late List<int> navigatedPages;
    late List<bool> navigatedSkipFlags;

    setUp(() {
      timerController = _TimerController();
      navigatedPages = [];
      navigatedSkipFlags = [];
    });

    SlideshowController createController({
      SlideshowOptions options = const SlideshowOptions(),
      SlideshowAdvanceCallback? onBeforeAdvance,
    }) {
      return SlideshowController(
        onNavigateToPage: (page, skip) {
          navigatedPages.add(page);
          navigatedSkipFlags.add(skip);
          return Future.value();
        },
        options: options,
        onBeforeAdvance: onBeforeAdvance,
        createTimer: timerController.createTimer,
      );
    }

    group('lifecycle', () {
      test('stops advancing when stopped', () async {
        final controller = createController();

        controller.start(0, 5);
        await timerController.triggerNext();
        controller.stop();
        timerController.clearHistory();
        await timerController.triggerNext();

        expect(navigatedPages.length, 1);
      });

      test('resume restarts timer and sets active state', () {
        final controller = createController();

        controller.start(0, 5);
        controller.stop();

        expect(controller.isRunning, false);

        controller.resume();

        expect(controller.isRunning, true);
      });

      test('resets random pages when restarted', () async {
        final controller = createController(
          options: const SlideshowOptions(
            direction: SlideshowDirection.random,
          ),
        );

        controller.start(0, 3);
        await timerController.triggerNext();
        await timerController.triggerNext();

        controller.stop();
        navigatedPages.clear();

        controller.start(0, 3);
        await timerController.triggerNext();
        await timerController.triggerNext();

        // Should generate new random sequence
        expect(navigatedPages.length, 2);
      });
    });

    group('direction', () {
      final forwardNavigationCases = [
        (
          description: 'advances to next page after timer triggers',
          startPage: 0,
          totalPages: 5,
          expected: [1],
        ),
        (
          description: 'wraps to first page after last page',
          startPage: 4,
          totalPages: 5,
          expected: [0],
        ),
      ];

      for (final c in forwardNavigationCases) {
        test(c.description, () async {
          final controller = createController();

          controller.start(c.startPage, c.totalPages);
          await timerController.triggerNext();

          expect(navigatedPages, c.expected);
        });
      }

      final backwardNavigationCases = [
        (
          description: 'advances backward correctly',
          startPage: 2,
          totalPages: 5,
          expected: [1],
        ),
        (
          description: 'wraps to last page when going backward from first page',
          startPage: 0,
          totalPages: 5,
          expected: [4],
        ),
      ];

      for (final c in backwardNavigationCases) {
        test(c.description, () async {
          final controller = createController(
            options: const SlideshowOptions(
              direction: SlideshowDirection.backward,
            ),
          );

          controller.start(c.startPage, c.totalPages);
          await timerController.triggerNext();

          expect(navigatedPages, c.expected);
        });
      }

      test(
        'advances to random pages without duplicates until all seen',
        () async {
          final controller = createController(
            options: const SlideshowOptions(
              direction: SlideshowDirection.random,
            ),
          );

          controller.start(0, 3);

          final seenPages = <int>{};
          for (var i = 0; i < 3; i++) {
            await timerController.triggerNext();
            seenPages.add(navigatedPages[i]);
          }

          expect(seenPages.length, 3);
          expect(seenPages, containsAll([0, 1, 2]));
        },
      );
    });

    group('transition behavior', () {
      final skipAnimationCases = [
        (
          duration: const Duration(milliseconds: 500),
          skipTransition: false,
          expected: true,
          description: 'skips animation for duration less than 1 second',
        ),
        (
          duration: const Duration(seconds: 2),
          skipTransition: true,
          expected: true,
          description: 'skips animation when skipTransition is true',
        ),
        (
          duration: const Duration(seconds: 2),
          skipTransition: false,
          expected: false,
          description: 'does not skip animation for duration >= 1 second',
        ),
      ];

      for (final c in skipAnimationCases) {
        test(c.description, () async {
          final controller = createController(
            options: SlideshowOptions(
              duration: c.duration,
              skipTransition: c.skipTransition,
            ),
          );

          controller.start(0, 5);
          await timerController.triggerNext();

          expect(navigatedSkipFlags.first, c.expected);
        });
      }
    });

    group('callbacks', () {
      test('invokes onBeforeAdvance with current and next page', () async {
        final calls = <(int, int)>[];

        final controller = createController(
          onBeforeAdvance: (current, next) async {
            calls.add((current, next));
          },
        );

        controller.start(0, 3);
        await timerController.triggerNext();
        await timerController.triggerNext();

        expect(calls, [(0, 1), (1, 2)]);
      });
    });
  });
}
