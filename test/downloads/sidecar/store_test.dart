// Dart imports:
import 'dart:io';

// Package imports:
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

// Project imports:
import 'package:boorusama/core/downloads/sidecar/data.dart';
import 'package:boorusama/core/downloads/sidecar/types.dart';
import 'package:boorusama/foundation/filesystem.dart';

void main() {
  late Directory root;
  late SidecarStore store;
  late File media;
  final snapshot = SidecarSnapshot(
    format: SidecarFormat.tags,
    tags: const ['zebra', 'artist:someone', 'zebra'],
    quality: 'original',
  );

  setUp(() async {
    root = await Directory.systemTemp.createTemp('sidecar-test-');
    store = SidecarStore(
      directory: p.join(root.path, 'intents'),
      fs: const IoFileSystem(),
    );
    media = File(p.join(root.path, 'downloads', 'art.jpg'));
  });
  tearDown(() => root.delete(recursive: true));

  test(
    'waits for confirmed completion, even when media already exists',
    () async {
      await store.prepare('download-1', media.path, snapshot);
      await media.writeAsString('existing media');

      await SidecarStore(directory: store.directory, fs: store.fs).recover();
      await expectLater(store.retry('download-1'), throwsStateError);
      expect(File('${media.path}.txt').existsSync(), isFalse);

      await SidecarStore(
        directory: store.directory,
        fs: store.fs,
      ).complete('download-1', media.path);
      expect(
        await File('${media.path}.txt').readAsString(),
        'artist:someone\nzebra\n',
      );
      expect(await store.failures(), isEmpty);
      await store.complete('download-1', media.path);
      expect(
        await Directory(
          store.directory,
        ).list(recursive: true).where((entry) => entry is File).toList(),
        isEmpty,
      );
    },
  );

  test(
    'failed metadata survives restart and retry never changes media',
    () async {
      await store.prepare('download-2', media.path, snapshot);
      await media.writeAsString('downloaded media');
      final destination = File('${media.path}.txt');
      await destination.writeAsString('user metadata');

      await expectLater(
        store.complete('download-2', media.path),
        throwsStateError,
      );
      final restarted = SidecarStore(directory: store.directory, fs: store.fs);
      expect((await restarted.failures()).single.id, 'download-2');
      await restarted.recover();
      expect(await destination.readAsString(), 'user metadata');
      expect((await restarted.failures()).single.path, media.path);

      await destination.delete();
      await restarted.retry('download-2');
      expect(await destination.readAsString(), 'artist:someone\nzebra\n');
      expect(await media.readAsString(), 'downloaded media');
      expect(await restarted.failures(), isEmpty);
    },
  );

  test(
    'completion uses the final filename, cancellation writes nothing',
    () async {
      await store.prepare('download-3', media.path, snapshot);
      final renamed = File(p.join(media.parent.path, 'art.webp'));
      await renamed.writeAsString('media');
      await store.complete('download-3', renamed.path);
      expect(File('${renamed.path}.txt').existsSync(), isTrue);
      expect(File('${media.path}.txt').existsSync(), isFalse);

      await store.prepare('download-4', media.path, snapshot);
      await store.discard('download-4');
      await store.complete('download-4', media.path);
      expect(File('${media.path}.txt').existsSync(), isFalse);
    },
  );

  test('replayed completion and failure polling can overlap', () async {
    await store.prepare('replayed', media.path, snapshot);
    await media.writeAsString('media');
    await Future.wait([
      store.complete('replayed', media.path),
      SidecarStore(
        directory: store.directory,
        fs: store.fs,
      ).complete('replayed', media.path),
      store.failures(),
    ]);
    expect(
      await File('${media.path}.txt').readAsString(),
      'artist:someone\nzebra\n',
    );
    expect(await store.failures(), isEmpty);
  });

  test(
    'invalid line-based tags fail before a download intent is saved',
    () async {
      await expectLater(
        store.prepare(
          'invalid',
          media.path,
          SidecarSnapshot(
            format: SidecarFormat.tags,
            tags: const ['one\ntwo'],
            quality: 'original',
          ),
        ),
        throwsFormatException,
      );
      expect(Directory(store.directory).existsSync(), isFalse);
      expect(media.existsSync(), isFalse);
    },
  );
}
