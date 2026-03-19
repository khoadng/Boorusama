// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../../foundation/database/providers.dart';
import '../../../../../foundation/database/utils.dart';
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/loggers.dart';
import '../types/tag_cache_repository.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Tags';
const kTagCacheDbName = 'tags.db';

final tagCacheRepositoryProvider = FutureProvider<TagCacheRepository>(
  (ref) async {
    final logger = ref.watch(loggerProvider);
    final dbFolderPath = await ref.watch(databaseFolderPathProvider.future);

    final fs = ref.watch(appFileSystemProvider);
    final db = await createDb(
      fs: fs,
      folderPath: dbFolderPath,
      name: kTagCacheDbName,
      logger: logger,
    );

    if (db == null) {
      logger.warn(_kServiceName, 'Fallback to empty tag cache repository');
      return EmptyTagCacheRepository();
    }

    final repo = TagCacheRepositorySqlite(db: db);

    ref.onDispose(() {
      repo.dispose();
    });

    try {
      return repo..initialize();
    } on Exception catch (e) {
      logger
        ..error(
          _kServiceName,
          'Failed to initialize SQLite database for tag cache: $e',
        )
        ..warn(_kServiceName, 'Fallback to empty tag cache repository');

      await repo.dispose();
      return EmptyTagCacheRepository();
    }
  },
);

Future<String> getTagCacheDbPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data', kTagCacheDbName);
}
