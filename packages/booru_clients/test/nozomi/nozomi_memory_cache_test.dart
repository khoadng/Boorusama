import 'dart:async';

import 'package:booru_clients/src/nozomi/nozomi_memory_cache.dart';
import 'package:test/test.dart';

void main() {
  group('NozomiMemoryCache', () {
    test('shares in-flight loads for the same key', () async {
      final cache = NozomiMemoryCache<List<int>>();
      final completer = Completer<List<int>>();
      var loads = 0;

      final first = cache.getOrLoad('tag', () {
        loads++;
        return completer.future;
      });
      final second = cache.getOrLoad('tag', () {
        loads++;
        return Future.value([2]);
      });

      expect(identical(first, second), isTrue);
      expect(loads, 1);

      completer.complete([1]);

      expect(await first, [1]);
      expect(await second, [1]);
    });

    test('reloads expired entries', () async {
      var now = DateTime(2026);
      final cache = NozomiMemoryCache<int>(
        ttl: const Duration(minutes: 5),
        now: () => now,
      );
      var loads = 0;

      expect(await cache.getOrLoad('tag', () async => ++loads), 1);
      expect(await cache.getOrLoad('tag', () async => ++loads), 1);

      now = now.add(const Duration(minutes: 6));

      expect(await cache.getOrLoad('tag', () async => ++loads), 2);
    });

    test('returns manually stored entries', () async {
      final cache = NozomiMemoryCache<List<int>>();

      cache.set('tag', [1, 2, 3], estimateCost: (ids) => ids.length);

      expect(await cache.get('tag'), [1, 2, 3]);
      expect(cache.length, 1);
      expect(cache.totalCost, 3);
    });

    test('evicts least recently used entries when full', () async {
      final cache = NozomiMemoryCache<String>(maxEntries: 2);
      var loads = 0;

      await cache.getOrLoad('a', () async => 'a-${++loads}');
      await cache.getOrLoad('b', () async => 'b-${++loads}');
      await cache.getOrLoad('a', () async => 'a-${++loads}');
      await cache.getOrLoad('c', () async => 'c-${++loads}');

      expect(await cache.getOrLoad('a', () async => 'a-${++loads}'), 'a-1');
      expect(await cache.getOrLoad('b', () async => 'b-${++loads}'), 'b-4');
    });

    test(
      'does not keep entries larger than the configured total cost',
      () async {
        final cache = NozomiMemoryCache<List<int>>(maxTotalCost: 2);
        var loads = 0;

        expect(
          await cache.getOrLoad(
            'huge-tag',
            () async {
              loads++;
              return [1, 2, 3];
            },
            estimateCost: (ids) => ids.length,
          ),
          [1, 2, 3],
        );
        expect(cache.length, 0);

        await cache.getOrLoad(
          'huge-tag',
          () async {
            loads++;
            return [4, 5, 6];
          },
          estimateCost: (ids) => ids.length,
        );

        expect(loads, 2);
      },
    );

    test('removes failed loads so later calls can retry', () async {
      final cache = NozomiMemoryCache<int>();
      var loads = 0;

      await expectLater(
        cache.getOrLoad('tag', () async {
          loads++;
          throw StateError('failed');
        }),
        throwsStateError,
      );

      expect(await cache.getOrLoad('tag', () async => ++loads), 2);
    });
  });
}
