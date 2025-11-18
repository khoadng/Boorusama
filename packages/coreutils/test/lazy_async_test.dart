import 'dart:async';

import 'package:coreutils/src/lazy_async.dart';
import 'package:test/test.dart';

void main() {
  group('LazyAsync', () {
    group('initialization', () {
      test('initializes value on first call', () async {
        var callCount = 0;
        final lazy = LazyAsync(() async {
          callCount++;
          return 'initialized';
        });

        expect(lazy.isInitialized, false);

        final result = await lazy();

        expect(result, 'initialized');
        expect(callCount, 1);
        expect(lazy.isInitialized, true);
      });

      test('returns cached value on subsequent calls', () async {
        var callCount = 0;
        final lazy = LazyAsync(() async {
          callCount++;
          return 'value';
        });

        final first = await lazy();
        final second = await lazy();
        final third = await lazy();

        expect(first, 'value');
        expect(second, 'value');
        expect(third, 'value');
        expect(callCount, 1);
      });

      test('resets and reinitializes after reset', () async {
        var callCount = 0;
        final lazy = LazyAsync(() async {
          callCount++;
          return 'value_$callCount';
        });

        final first = await lazy();
        expect(first, 'value_1');
        expect(lazy.isInitialized, true);

        lazy.reset();
        expect(lazy.isInitialized, false);

        final second = await lazy();
        expect(second, 'value_2');
        expect(callCount, 2);
      });
    });

    group('concurrency', () {
      test('handles concurrent initialization calls', () async {
        var callCount = 0;
        final lazy = LazyAsync(() async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 100));
          return 'concurrent';
        });

        final call1 = lazy();
        final call2 = lazy();
        final call3 = lazy();

        final results = await Future.wait([
          Future.value(call1),
          Future.value(call2),
          Future.value(call3),
        ]);

        expect(results, ['concurrent', 'concurrent', 'concurrent']);
        expect(callCount, 1);
      });

      test('concurrent calls during init all return same Future', () async {
        var callCount = 0;
        final lazy = LazyAsync(() async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 50));
          return 'shared';
        });

        final call1 = lazy();
        final call2 = lazy();
        final call3 = lazy();

        expect(call1 is Future, true);
        expect(call2 is Future, true);
        expect(call3 is Future, true);

        expect(identical(call1, call2), true);
        expect(identical(call2, call3), true);

        final results = await Future.wait([
          Future.value(call1),
          Future.value(call2),
          Future.value(call3),
        ]);

        expect(results, ['shared', 'shared', 'shared']);
        expect(callCount, 1);
      });
    });

    group('type handling', () {
      final typeCases = [
        (value: 42, type: 'int'),
        (value: [1, 2, 3], type: 'List'),
        (value: {'key': 'value'}, type: 'Map'),
      ];
      for (final c in typeCases) {
        test('caches ${c.type} values correctly', () async {
          final lazy = LazyAsync(() async => c.value);
          expect(await lazy(), c.value);
        });
      }

      test('caches null values correctly', () async {
        var callCount = 0;
        final lazy = LazyAsync<String?>(() async {
          callCount++;
          return null;
        });

        final first = await lazy();
        final second = await lazy();
        final third = await lazy();

        expect(first, null);
        expect(second, null);
        expect(third, null);
        expect(callCount, 1);
      });

      test('handles nullable types with non-null values', () async {
        var callCount = 0;
        final lazy = LazyAsync<int?>(() async {
          callCount++;
          return 42;
        });

        final first = await lazy();
        final second = await lazy();

        expect(first, 42);
        expect(second, 42);
        expect(callCount, 1);
      });
    });

    group('error handling', () {
      test('propagates exceptions from factory', () async {
        final lazy = LazyAsync<String>(() async {
          throw Exception('initialization failed');
        });

        expect(
          () async => await lazy(),
          throwsA(isA<Exception>()),
        );
      });

      test('retries after exception (exceptions are not cached)', () async {
        var callCount = 0;
        final lazy = LazyAsync<String>(() async {
          callCount++;
          if (callCount < 3) {
            throw Exception('Transient failure $callCount');
          }
          return 'success';
        });

        try {
          await lazy();
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<Exception>());
        }
        expect(callCount, 1);

        try {
          await lazy();
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<Exception>());
        }
        expect(callCount, 2);

        final result = await lazy();
        expect(result, 'success');
        expect(callCount, 3);
      });

      test('handles concurrent calls when factory throws', () async {
        var callCount = 0;
        final lazy = LazyAsync<String>(() async {
          callCount++;
          await Future.delayed(Duration(milliseconds: 50));
          throw Exception('Always fails');
        });

        final call1 = lazy();
        final call2 = lazy();
        final call3 = lazy();

        try {
          await Future.wait([
            Future.value(call1),
            Future.value(call2),
            Future.value(call3),
          ]);
          fail('Should have thrown');
        } catch (e) {
          expect(e, isA<Exception>());
        }

        expect(callCount, 1);
      });
    });

    group('synchronous return optimization', () {
      test('returns synchronously after initialization', () async {
        var callCount = 0;
        final lazy = LazyAsync(() async {
          callCount++;
          return 'initialized';
        });

        final firstResult = await lazy();
        expect(firstResult, 'initialized');
        expect(callCount, 1);

        final secondResult = lazy();
        expect(secondResult, 'initialized');
        expect(secondResult is String, true);
        expect(secondResult is! Future, true);
        expect(callCount, 1);
      });

      test('returns Future during initialization', () async {
        final lazy = LazyAsync(() async {
          await Future.delayed(Duration(milliseconds: 50));
          return 'value';
        });

        final result = lazy();
        expect(result is Future<String>, true);
        expect(result is! String, true);
        expect(await result, 'value');
      });

      test(
        'first call returns Future, subsequent calls return value directly',
        () async {
          final lazy = LazyAsync(() async {
            await Future.delayed(Duration(milliseconds: 10));
            return 42;
          });

          final firstCall = lazy();
          expect(firstCall is Future<int>, true);
          expect(firstCall is! int, true);

          final firstResult = await firstCall;
          expect(firstResult, 42);

          final secondCall = lazy();
          expect(secondCall is int, true);
          expect(secondCall is! Future, true);
          expect(secondCall, 42);

          final thirdCall = lazy();
          expect(thirdCall is int, true);
          expect(thirdCall, 42);
        },
      );

      test('post-initialization calls execute synchronously', () async {
        var microtasksRan = 0;
        final lazy = LazyAsync(() async => 'value');

        await lazy();

        scheduleMicrotask(() => microtasksRan++);

        final result = lazy();

        expect(result, 'value');
        expect(microtasksRan, 0);

        await Future.microtask(() {
          expect(microtasksRan, 1);
        });
      });
    });
  });
}
