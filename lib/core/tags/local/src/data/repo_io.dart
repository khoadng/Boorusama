// Package imports:
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' show join;

// Project imports:
import '../../../../../foundation/database/utils.dart';
import '../../../../../foundation/filesystem.dart';
import '../../../../../foundation/loggers.dart';
import '../types/tag_cache_repository.dart';
import '../types/tag_cache_repository_factory.dart';
import 'repo_empty.dart';
import 'repo_sqlite.dart';

const _kServiceName = 'Tags';
const kTagCacheDbName = 'tags.db';

final tagCacheRepositoryFactoryProvider = Provider<TagCacheRepositoryFactory>(
  (ref) => SqliteTagCacheRepositoryFactory(
    fileSystem: ref.watch(appFileSystemProvider),
    logger: ref.watch(loggerProvider),
  ),
);

final tagCacheRepositoryProvider = FutureProvider<TagCacheRepository>(
  (ref) async {
    final factory = ref.watch(tagCacheRepositoryFactoryProvider);
    final repository = await factory.create();
    ref.onDispose(() => factory.dispose(repository));
    return repository;
  },
);

final class SqliteTagCacheRepositoryFactory
    implements TagCacheRepositoryFactory {
  const SqliteTagCacheRepositoryFactory({
    required this.fileSystem,
    required this.logger,
  });

  final AppFileSystem fileSystem;
  final Logger logger;

  @override
  Future<TagCacheRepository> create() async {
    final dbFolderPath = await getTagCacheDbFolderPath(fileSystem);
    final db = await createDb(
      fs: fileSystem,
      folderPath: dbFolderPath,
      name: kTagCacheDbName,
      logger: logger,
    );

    if (db == null) {
      logger.warn(_kServiceName, 'Fallback to empty tag cache repository');
      return EmptyTagCacheRepository();
    }

    final repo = TagCacheRepositorySqlite(db: db);
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
  }

  @override
  Future<void> dispose(TagCacheRepository repository) => repository.dispose();
}

Future<String> getTagCacheDbFolderPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data');
}

Future<String> getTagCacheDbPath(AppFileSystem fs) async {
  final basePath = await fs.getAppStoragePath();
  return join(basePath, 'data', kTagCacheDbName);
}
