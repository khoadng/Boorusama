import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:boorusama/core/videos/engines/types.dart';
import 'package:boorusama/core/videos/player/src/widgets/video_player.dart';

class MockBooruPlayer extends Mock implements BooruPlayer {}

void main() {
  group('defaultPlayerDisposer', () {
    late MockBooruPlayer player;
    late Completer<void> disposalCompleter;

    setUp(() {
      player = MockBooruPlayer();
      disposalCompleter = Completer<void>();

      when(() => player.setVolume(any())).thenAnswer((_) async {});
      when(() => player.pause()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
      });
      when(() => player.dispose()).thenAnswer((_) {
        disposalCompleter.complete();
      });
    });

    test('disposal completes before function returns', () async {
      await defaultPlayerDisposer(player);

      expect(
        disposalCompleter.isCompleted,
        isTrue,
        reason: 'Disposal should complete before defaultPlayerDisposer returns',
      );
    });

    test('rapid disposal calls complete sequentially', () async {
      final players = <MockBooruPlayer>[];
      final completers = <Completer<void>>[];

      for (var i = 0; i < 3; i++) {
        final p = MockBooruPlayer();
        final c = Completer<void>();
        players.add(p);
        completers.add(c);

        when(() => p.setVolume(any())).thenAnswer((_) async {});
        when(() => p.pause()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 30 + i * 10));
        });
        when(() => p.dispose()).thenAnswer((_) {
          c.complete();
        });
      }

      for (final p in players) {
        await defaultPlayerDisposer(p);
      }

      final allCompleted = completers.every((c) => c.isCompleted);
      expect(
        allCompleted,
        isTrue,
        reason:
            'All disposals should complete before their respective calls return',
      );
    });

    test('no concurrent disposal operations', () async {
      var activeDisposals = 0;
      var maxConcurrent = 0;

      final players = <MockBooruPlayer>[];
      for (var i = 0; i < 3; i++) {
        final p = MockBooruPlayer();
        players.add(p);

        when(() => p.setVolume(any())).thenAnswer((_) async {});
        when(() => p.pause()).thenAnswer((_) async {
          activeDisposals++;
          maxConcurrent = activeDisposals > maxConcurrent
              ? activeDisposals
              : maxConcurrent;
          await Future.delayed(const Duration(milliseconds: 30));
          activeDisposals--;
        });
        when(() => p.dispose()).thenReturn(null);
      }

      for (final p in players) {
        await defaultPlayerDisposer(p);
      }

      expect(
        maxConcurrent,
        1,
        reason: 'Only one disposal should be active at a time',
      );
    });
  });
}
